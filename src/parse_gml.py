"""
Parse CityGML 2.0 + EnergyADE 3.0 GML files into BuildingModel list.

Rich path (buildings with nrg3:thermalZone):
  zones = ThermalZone elements, surfaces = thermalBoundary children, windows = bldg:opening/bldg:Window

Poor path (no thermalZone):
  one synthetic zone per building from bldg:boundedBy surfaces; archetype-derived constructions.
"""
import logging
from typing import Optional

from lxml import etree

from .model import BuildingModel, Zone, Surface, Opening, Construction, Material, NoMassMaterial, GasMaterial
from .geometry import parse_poslist, compute_origin, translate_verts, centroid, orient_outward
from .constructions import resolve_construction, archetype_constructions
from .archetypes import ArchetypeTable

logger = logging.getLogger(__name__)

NS = {
    'gml': 'http://www.opengis.net/gml',
    'bldg': 'http://www.opengis.net/citygml/building/2.0',
    'core': 'http://www.opengis.net/citygml/2.0',
    'nrg3': 'http://www.citygml.org/ade/energy/3.0',
    'gen': 'http://www.opengis.net/citygml/generics/2.0',
    'xlink': 'http://www.w3.org/1999/xlink',
}

XLINK = '{http://www.w3.org/1999/xlink}'
GML = '{http://www.opengis.net/gml}'
BLDG = '{http://www.opengis.net/citygml/building/2.0}'
NRG3 = '{http://www.citygml.org/ade/energy/3.0}'
GEN = '{http://www.opengis.net/citygml/generics/2.0}'


def _txt(elem, path: str) -> Optional[str]:
    child = elem.find(path, NS)
    return child.text.strip() if child is not None and child.text else None


def _ftxt(elem, path: str) -> Optional[float]:
    t = _txt(elem, path)
    return float(t) if t is not None else None


def _resolve_href(href: str) -> str:
    """Strip leading # from xlink:href."""
    return href.lstrip('#') if href else ''


def build_id_index(trees: list) -> dict:
    """Build gml:id → element dict across all parsed trees."""
    index = {}
    for tree in trees:
        root = tree.getroot() if hasattr(tree, 'getroot') else tree
        for elem in root.iter():
            gid = elem.get(f'{GML}id')
            if gid:
                index[gid] = elem
    return index


def _extract_polygon_verts(poly_elem, lod: str = '2') -> Optional[list]:
    """Extract exterior ring vertices from a gml:Polygon element."""
    ext = poly_elem.find('gml:exterior/gml:LinearRing/gml:posList', NS)
    if ext is not None and ext.text:
        return parse_poslist(ext.text)
    ext = poly_elem.find('gml:exterior/gml:LinearRing', NS)
    if ext is not None:
        coords_el = ext.find('gml:coordinates', NS)
        if coords_el is not None and coords_el.text:
            pairs = coords_el.text.strip().split()
            verts = []
            for p in pairs:
                parts = p.split(',')
                if len(parts) >= 3:
                    verts.append((float(parts[0]), float(parts[1]), float(parts[2])))
                elif len(parts) == 2:
                    verts.append((float(parts[0]), float(parts[1]), 0.0))
            if verts and verts[-1] == verts[0]:
                verts = verts[:-1]
            return verts if verts else None
    return None


def _get_surface_verts(surf_elem, id_index: dict, prefer_lod: str = '2') -> Optional[list]:
    """
    Resolve geometry for a bldg:*Surface or nrg3:thermalBoundary child element.
    Tries lod2MultiSurface first (prefer_lod='2') then lod3MultiSurface, or vice versa.
    Returns vertex list (exterior ring only, no window holes).
    """
    lod_order = ['lod2MultiSurface', 'lod3MultiSurface'] if prefer_lod == '2' else ['lod3MultiSurface', 'lod2MultiSurface']

    for lod_tag in lod_order:
        multi_el = surf_elem.find(f'bldg:{lod_tag}', NS)
        if multi_el is None:
            multi_el = surf_elem.find(f'nrg3:{lod_tag}', NS)
        if multi_el is None:
            continue

        for sm in multi_el.findall('.//gml:surfaceMember', NS):
            href = sm.get(f'{XLINK}href', '')
            if href:
                poly_id = _resolve_href(href)
                poly_elem = id_index.get(poly_id)
                if poly_elem is not None:
                    verts = _extract_polygon_verts(poly_elem)
                    if verts:
                        return verts
            else:
                poly_el = sm.find('gml:Polygon', NS)
                if poly_el is not None:
                    verts = _extract_polygon_verts(poly_el)
                    if verts:
                        return verts

    return None


def _get_window_verts(win_elem, id_index: dict) -> Optional[list]:
    """Extract window polygon vertices (LoD3 exterior ring)."""
    multi_el = win_elem.find('bldg:lod3MultiSurface', NS)
    if multi_el is None:
        return None
    for sm in multi_el.findall('.//gml:surfaceMember', NS):
        href = sm.get(f'{XLINK}href', '')
        if href:
            poly_elem = id_index.get(_resolve_href(href))
            if poly_elem is not None:
                verts = _extract_polygon_verts(poly_elem)
                if verts:
                    return verts
        else:
            poly_el = sm.find('gml:Polygon', NS)
            if poly_el is not None:
                verts = _extract_polygon_verts(poly_el)
                if verts:
                    return verts
    return None


def _surface_type_from_tag(elem) -> str:
    tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag
    mapping = {
        'WallSurface': 'wall',
        'RoofSurface': 'roof',
        'GroundSurface': 'ground',
        'FloorSurface': 'floor',
        'InteriorWallSurface': 'interior',
        'CeilingSurface': 'interior',
        'ClosureSurface': 'interior',
        'PartyWallSurface': 'party',
    }
    return mapping.get(tag, 'wall')


def _boundary_condition(surf_elem, stype: str, is_adiabatic: bool) -> tuple:
    """
    Determine E+ boundary condition and optional adj surface id.
    Reads gen:stringAttribute adjacentSurface/adjacentZone if present.
    Returns (boundary_str, adj_surface_id).
    """
    adj_surface_id = None

    # Check injected adjacency attributes (from enrich_adjacency.py)
    for ga in surf_elem.findall('gen:stringAttribute', NS):
        name = ga.get('name', '')
        val_el = ga.find('gen:value', NS)
        val = val_el.text.strip() if val_el is not None and val_el.text else ''
        if name == 'adjacentSurface' and val:
            adj_surface_id = val

    if adj_surface_id:
        return 'surface', adj_surface_id

    if is_adiabatic or stype in ('party', 'interior'):
        return 'adiabatic', None

    if stype == 'ground':
        return 'ground', None

    return 'outdoors', None


def _parse_rich_building(bldg_elem, id_index: dict, prefer_lod: str = '2') -> BuildingModel:
    """Parse building with nrg3:thermalZone data."""
    bldg_id = bldg_elem.get(f'{GML}id', 'unknown')
    bldg_name = _txt(bldg_elem, 'gml:name') or bldg_id

    all_constructions = {}
    all_materials = {}
    zones = []

    # Collect all vertices across building for origin
    all_verts_lists = []

    # First pass: collect all vertex data to compute origin
    # Search recursively to handle BuildingPart children
    for tz_wrapper in bldg_elem.findall('.//nrg3:thermalZone', NS):
        for tz in tz_wrapper.findall('nrg3:ThermalZone', NS):
            for tb_wrapper in tz.findall('nrg3:thermalBoundary', NS):
                for surf_child in tb_wrapper:
                    verts = _get_surface_verts(surf_child, id_index, prefer_lod)
                    if verts:
                        all_verts_lists.append(verts)
                    for win_wrapper in surf_child.findall('bldg:opening', NS):
                        for win in win_wrapper.findall('bldg:Window', NS):
                            wv = _get_window_verts(win, id_index)
                            if wv:
                                all_verts_lists.append(wv)

    origin = compute_origin(all_verts_lists)

    # Second pass: build Zones and Surfaces (recursive for BuildingParts)
    for tz_wrapper in bldg_elem.findall('.//nrg3:thermalZone', NS):
        for tz in tz_wrapper.findall('nrg3:ThermalZone', NS):
            zone_id = tz.get(f'{GML}id', 'zone_unknown')
            zone_name = _txt(tz, 'gml:name') or zone_id

            surfaces = []
            zone_verts_for_centroid = []

            for tb_wrapper in tz.findall('nrg3:thermalBoundary', NS):
                for surf_child in tb_wrapper:
                    surf_id = surf_child.get(f'{GML}id', '')
                    if not surf_id:
                        continue

                    stype = _surface_type_from_tag(surf_child)
                    is_adiabatic_txt = _txt(surf_child, 'nrg3:bdgBdrySurfIsAdiabatic')
                    is_adiabatic = is_adiabatic_txt is not None and is_adiabatic_txt.lower() == 'true'

                    boundary, adj_surf_id = _boundary_condition(surf_child, stype, is_adiabatic)

                    # Resolve construction
                    constr_href = ''
                    lc_el = surf_child.find('nrg3:layeredConstruction', NS)
                    if lc_el is not None:
                        constr_href = _resolve_href(lc_el.get(f'{XLINK}href', ''))

                    # Get geometry
                    verts = _get_surface_verts(surf_child, id_index, prefer_lod)
                    if not verts:
                        logger.warning("No geometry for surface %s; skipping", surf_id)
                        continue

                    zone_verts_for_centroid.extend(verts)
                    local_verts = translate_verts(verts, origin)

                    # Resolve windows
                    openings = []
                    for win_wrapper in surf_child.findall('bldg:opening', NS):
                        for win in win_wrapper.findall('bldg:Window', NS):
                            win_id = win.get(f'{GML}id', '')
                            win_verts = _get_window_verts(win, id_index)
                            if not win_verts:
                                logger.warning("No geometry for window %s; skipping", win_id)
                                continue
                            local_win_verts = translate_verts(win_verts, origin)

                            win_constr_href = ''
                            win_lc_el = win.find('nrg3:layeredConstruction', NS)
                            if win_lc_el is not None:
                                win_constr_href = _resolve_href(win_lc_el.get(f'{XLINK}href', ''))

                            if win_constr_href:
                                wc, wm = resolve_construction(win_constr_href, id_index, is_glazing=True)
                                if wc:
                                    all_constructions[win_constr_href] = wc
                                    all_materials.update(wm)

                            openings.append(Opening(
                                id=win_id,
                                verts=local_win_verts,
                                constr_id=win_constr_href or None,
                            ))

                    # Resolve opaque construction
                    if constr_href:
                        c, m = resolve_construction(constr_href, id_index, is_glazing=False)
                        if c:
                            all_constructions[constr_href] = c
                            all_materials.update(m)

                    surfaces.append(Surface(
                        id=surf_id,
                        stype=stype,
                        verts=local_verts,
                        constr_id=constr_href or None,
                        boundary=boundary,
                        adj_surface_id=adj_surf_id,
                        openings=openings,
                    ))

            # Orient surfaces outward (use zone centroid as inside reference)
            if zone_verts_for_centroid:
                zone_centroid = centroid(translate_verts(zone_verts_for_centroid, origin))
            else:
                zone_centroid = (0.0, 0.0, 0.0)

            for s in surfaces:
                s.verts = orient_outward(s.verts, zone_centroid)
                for o in s.openings:
                    o.verts = orient_outward(o.verts, zone_centroid)

            zones.append(Zone(id=zone_id, name=zone_name, surfaces=surfaces))

    return BuildingModel(
        id=bldg_id,
        name=bldg_name,
        origin_xyz=origin,
        zones=zones,
        constructions=all_constructions,
        materials=all_materials,
    )


def _extract_lod1_surfaces(bldg_elem, id_index: dict) -> list:
    """
    Extract surfaces from bldg:lod1Solid CompositeSurface polygons.
    Returns list of (None, stype, verts) where stype is inferred from normal direction.
    Used as fallback when bldg:boundedBy is absent.
    """
    result = []
    for lod1 in bldg_elem.findall('.//bldg:lod1Solid', NS):
        for poly_el in lod1.findall('.//gml:Polygon', NS):
            verts = _extract_polygon_verts(poly_el)
            if not verts or len(verts) < 3:
                # Try xlink href polygon
                continue
            from .geometry import newell_normal
            normal = newell_normal(verts)
            nz = normal[2]
            if nz > 0.7:
                stype = 'roof'
            elif nz < -0.7:
                stype = 'ground'
            else:
                stype = 'wall'
            # Create a synthetic elem-like object (None — no XML element for attributes)
            result.append((None, stype, verts))
        for sm in lod1.findall('.//gml:surfaceMember', NS):
            href = sm.get(f'{XLINK}href', '')
            if href:
                poly_elem = id_index.get(href.lstrip('#'))
                if poly_elem is not None:
                    verts = _extract_polygon_verts(poly_elem)
                    if verts and len(verts) >= 3:
                        from .geometry import newell_normal
                        normal = newell_normal(verts)
                        nz = normal[2]
                        if nz > 0.7:
                            stype = 'roof'
                        elif nz < -0.7:
                            stype = 'ground'
                        else:
                            stype = 'wall'
                        result.append((None, stype, verts))
    return result


def _parse_poor_building(bldg_elem, id_index: dict, archetype_table: Optional[ArchetypeTable],
                          prefer_lod: str = '2') -> BuildingModel:
    """Parse building without thermalZone (poor path) — one zone, archetype constructions."""
    bldg_id = bldg_elem.get(f'{GML}id', 'unknown')
    bldg_name = _txt(bldg_elem, 'gml:name') or bldg_id

    # Building metadata for archetype lookup
    function = _txt(bldg_elem, 'bldg:function') or 'residential'
    year_txt = _txt(bldg_elem, 'bldg:yearOfConstruction')
    year = int(year_txt) if year_txt and year_txt.isdigit() else 1970
    weight = _txt(bldg_elem, 'nrg3:bdgConstructionWeight') or ''

    # Archetype lookup
    if archetype_table:
        arch_row = archetype_table.lookup(function, year, weight)
    else:
        from .archetypes import _DEFAULTS
        arch_row = dict(_DEFAULTS)
        logger.warning("No archetype table for poor-path building %s; using built-in defaults", bldg_id)

    arch_constrs, arch_mats, arch_type_map = archetype_constructions(bldg_id, arch_row)

    # Collect surface geometries from bldg:boundedBy (on Building + BuildingParts)
    all_verts_lists = []
    surf_data = []  # (surf_elem, stype)

    def _collect_bounded_by(elem):
        for bb in elem.findall('bldg:boundedBy', NS):
            for surf_child in bb:
                stype = _surface_type_from_tag(surf_child)
                verts = _get_surface_verts(surf_child, id_index, prefer_lod)
                if verts:
                    all_verts_lists.append(verts)
                    surf_data.append((surf_child, stype, verts))
        for part_wrapper in elem.findall('bldg:consistsOfBuildingPart', NS):
            for part in part_wrapper.findall('bldg:BuildingPart', NS):
                _collect_bounded_by(part)

    _collect_bounded_by(bldg_elem)

    # Fallback: extract surfaces from bldg:lod1Solid if no boundedBy surfaces found
    if not surf_data:
        surf_data = _extract_lod1_surfaces(bldg_elem, id_index)

    origin = compute_origin(all_verts_lists)

    all_local_verts = []
    surfaces = []
    for surf_child, stype, verts in surf_data:
        surf_id = (surf_child.get(f'{GML}id', '') if surf_child is not None else '')
        local_verts = translate_verts(verts, origin)
        all_local_verts.extend(local_verts)

        is_adiabatic = False
        boundary = 'ground' if stype == 'ground' else 'outdoors'
        adj_surf_id = None

        if surf_child is not None:
            is_adiabatic_txt = _txt(surf_child, 'nrg3:bdgBdrySurfIsAdiabatic')
            is_adiabatic = is_adiabatic_txt is not None and is_adiabatic_txt.lower() == 'true'
            boundary, adj_surf_id = _boundary_condition(surf_child, stype, is_adiabatic)

        if is_adiabatic or stype in ('party', 'interior'):
            boundary = 'adiabatic'
        elif stype == 'ground':
            boundary = 'ground'

        constr_id = arch_type_map.get(stype, arch_type_map.get('wall'))

        # Windows from WWR (no actual window geometry in poor path)
        openings = []
        if surf_child is not None and stype == 'wall':
            wwr_txt = _txt(surf_child, 'nrg3:bdgBdrySurfOpeningToSurfaceRatio')
            if wwr_txt:
                try:
                    wwr = float(wwr_txt)
                    if wwr > 0:
                        win_cid = arch_type_map.get('window')
                        openings.append(Opening(
                            id=f"{surf_id}_win_wwr",
                            verts=[],   # empty = WWR-based, no explicit geometry
                            constr_id=win_cid,
                        ))
                except ValueError:
                    pass

        surfaces.append(Surface(
            id=surf_id or f"{bldg_id}_surf_{len(surfaces)}",
            stype=stype,
            verts=local_verts,
            constr_id=constr_id,
            boundary=boundary,
            adj_surface_id=adj_surf_id,
            openings=openings,
        ))

    # Orient outward
    if all_local_verts:
        zone_centroid = centroid(all_local_verts)
    else:
        zone_centroid = (0.0, 0.0, 0.0)

    for s in surfaces:
        s.verts = orient_outward(s.verts, zone_centroid)

    zone = Zone(id=f"{bldg_id}_zone", name=f"{bldg_name} Zone", surfaces=surfaces)

    return BuildingModel(
        id=bldg_id,
        name=bldg_name,
        origin_xyz=origin,
        zones=[zone],
        constructions=arch_constrs,
        materials=arch_mats,
    )


def _parse_coincides_building(bldg_elem, id_index: dict, archetype_table: Optional[ArchetypeTable],
                              prefer_lod: str = '2') -> BuildingModel:
    """
    Building has nrg3:thermalZone but no thermalBoundary.
    Thermal zone hull coincides with LoD2. Use bldg:boundedBy geometry + archetype constructions.
    One zone per ThermalZone element found.
    """
    bldg_id = bldg_elem.get(f'{GML}id', 'unknown')
    bldg_name = _txt(bldg_elem, 'gml:name') or bldg_id

    # Building metadata for archetype lookup
    function = _txt(bldg_elem, 'bldg:function') or 'residential'
    year_txt = _txt(bldg_elem, 'bldg:yearOfConstruction')
    year = int(year_txt) if year_txt and year_txt.isdigit() else 1970
    weight = _txt(bldg_elem, 'nrg3:bdgConstructionWeight') or ''

    if archetype_table:
        arch_row = archetype_table.lookup(function, year, weight)
    else:
        from .archetypes import _DEFAULTS
        arch_row = dict(_DEFAULTS)
        logger.warning("No archetype table for coincides-hull building %s; using built-in defaults", bldg_id)

    arch_constrs, arch_mats, arch_type_map = archetype_constructions(bldg_id, arch_row)

    # Collect surfaces from bldg:boundedBy
    all_verts_lists = []
    surf_data = []
    for bb in bldg_elem.findall('bldg:boundedBy', NS):
        for surf_child in bb:
            stype = _surface_type_from_tag(surf_child)
            verts = _get_surface_verts(surf_child, id_index, prefer_lod)
            if verts:
                all_verts_lists.append(verts)
                surf_data.append((surf_child, stype, verts))

    origin = compute_origin(all_verts_lists)

    all_local_verts = []
    surfaces = []
    for surf_child, stype, verts in surf_data:
        surf_id = surf_child.get(f'{GML}id', f"{bldg_id}_surf_{len(surfaces)}")
        local_verts = translate_verts(verts, origin)
        all_local_verts.extend(local_verts)

        is_adiabatic_txt = _txt(surf_child, 'nrg3:bdgBdrySurfIsAdiabatic')
        is_adiabatic = is_adiabatic_txt is not None and is_adiabatic_txt.lower() == 'true'
        boundary, adj_surf_id = _boundary_condition(surf_child, stype, is_adiabatic)

        constr_id = arch_type_map.get(stype, arch_type_map.get('wall'))
        surfaces.append(Surface(
            id=surf_id,
            stype=stype,
            verts=local_verts,
            constr_id=constr_id,
            boundary=boundary,
            adj_surface_id=adj_surf_id,
        ))

    if all_local_verts:
        zone_centroid = centroid(all_local_verts)
    else:
        zone_centroid = (0.0, 0.0, 0.0)
    for s in surfaces:
        s.verts = orient_outward(s.verts, zone_centroid)

    # Use ThermalZone id(s) for the zone(s)
    tz_ids = []
    for tz_wrapper in bldg_elem.findall('nrg3:thermalZone', NS):
        for tz in tz_wrapper.findall('nrg3:ThermalZone', NS):
            tz_ids.append((tz.get(f'{GML}id', f"{bldg_id}_zone"), _txt(tz, 'gml:name') or ''))

    if not tz_ids:
        tz_ids = [(f"{bldg_id}_zone", f"{bldg_name} Zone")]

    # For multiple thermal zones in coincides-hull case, assign all surfaces to first zone
    zone_id, zone_name = tz_ids[0]
    if not zone_name:
        zone_name = f"{bldg_name} Zone"
    zone = Zone(id=zone_id, name=zone_name, surfaces=surfaces)

    return BuildingModel(
        id=bldg_id,
        name=bldg_name,
        origin_xyz=origin,
        zones=[zone],
        constructions=arch_constrs,
        materials=arch_mats,
    )


def parse_gml(
    main_file: str,
    library_files: Optional[list] = None,
    archetype_table: Optional[ArchetypeTable] = None,
    prefer_lod: str = '2',
) -> list:
    """
    Parse one or more GML files → list of BuildingModel.
    main_file: path to main GML.
    library_files: optional list of additional GML paths for cross-file xlink resolution.
    """
    files = [main_file] + (library_files or [])
    trees = []
    for f in files:
        logger.info("Parsing %s", f)
        tree = etree.parse(f)
        trees.append(tree)

    id_index = build_id_index(trees)
    logger.info("ID index: %d elements", len(id_index))

    main_tree = trees[0]
    root = main_tree.getroot()

    buildings = root.findall('.//bldg:Building', NS)
    logger.info("Found %d Building elements", len(buildings))

    result = []
    for bldg_elem in buildings:
        bldg_id = bldg_elem.get(f'{GML}id', 'unknown')
        # Use recursive search to catch thermalZone inside BuildingPart children
        has_thermal = bool(bldg_elem.findall('.//nrg3:thermalZone', NS))
        has_thermal_boundary = bool(bldg_elem.findall('.//nrg3:thermalBoundary', NS))

        if has_thermal and has_thermal_boundary:
            logger.debug("Building %s → rich path", bldg_id)
            bm = _parse_rich_building(bldg_elem, id_index, prefer_lod)
        elif has_thermal and not has_thermal_boundary:
            # ThermalZone present but hull coincides with LoD2 → use bldg:boundedBy
            logger.debug("Building %s → coincides-with-hull path (thermalZone, no thermalBoundary)", bldg_id)
            bm = _parse_coincides_building(bldg_elem, id_index, archetype_table, prefer_lod)
        else:
            logger.debug("Building %s → poor path (archetype)", bldg_id)
            bm = _parse_poor_building(bldg_elem, id_index, archetype_table, prefer_lod)

        result.append(bm)
        logger.info(
            "Building %s: %d zones, %d constructions, %d materials",
            bm.id, len(bm.zones), len(bm.constructions), len(bm.materials),
        )

    return result
