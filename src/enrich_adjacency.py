"""
Standalone adjacency enrichment preprocessor.

Reads CityGML 2.0 + EnergyADE 3.0 → finds coplanar overlapping surface pairs
(shared interior / party walls) → writes adjacency back into GML as gen: attributes.

Fully decoupled: imports nothing from the converter modules.

CLI:
    python -m src.enrich_adjacency --input X.gml --output X_enriched.gml [--tol 0.01]
"""
import argparse
import logging
import math
import sys
from typing import Optional

from lxml import etree

logger = logging.getLogger(__name__)

# Namespaces
NS = {
    'gml': 'http://www.opengis.net/gml',
    'bldg': 'http://www.opengis.net/citygml/building/2.0',
    'core': 'http://www.opengis.net/citygml/2.0',
    'nrg3': 'http://www.citygml.org/ade/energy/3.0',
    'gen': 'http://www.opengis.net/citygml/generics/2.0',
    'xlink': 'http://www.w3.org/1999/xlink',
}

XLINK = '{http://www.w3.org/1999/xlink}'
GML_ID = '{http://www.opengis.net/gml}id'
GEN_NS = 'http://www.opengis.net/citygml/generics/2.0'
NRG3_NS = 'http://www.citygml.org/ade/energy/3.0'


# ─── Geometry helpers ───────────────────────────────────────────────────────

def _parse_poslist(text: str) -> list:
    vals = [float(v) for v in text.strip().split()]
    verts = [tuple(vals[i:i+3]) for i in range(0, len(vals), 3)]
    if len(verts) > 1 and verts[-1] == verts[0]:
        verts = verts[:-1]
    return verts


def _newell_normal(verts: list) -> tuple:
    n = len(verts)
    nx = ny = nz = 0.0
    for i in range(n):
        cur = verts[i]
        nxt = verts[(i + 1) % n]
        nx += (cur[1] - nxt[1]) * (cur[2] + nxt[2])
        ny += (cur[2] - nxt[2]) * (cur[0] + nxt[0])
        nz += (cur[0] - nxt[0]) * (cur[1] + nxt[1])
    mag = math.sqrt(nx * nx + ny * ny + nz * nz)
    if mag < 1e-10:
        return (0.0, 0.0, 1.0)
    return (nx / mag, ny / mag, nz / mag)


def _centroid(verts: list) -> tuple:
    n = len(verts)
    return (
        sum(v[0] for v in verts) / n,
        sum(v[1] for v in verts) / n,
        sum(v[2] for v in verts) / n,
    )


def _dot(a: tuple, b: tuple) -> float:
    return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]


def _plane_distance(normal: tuple, point: tuple, test_point: tuple) -> float:
    """Signed distance from test_point to plane defined by normal+point."""
    d = _dot(normal, point)
    return abs(_dot(normal, test_point) - d)


def _project_to_plane(verts: list, normal: tuple) -> list:
    """Project 3D verts to 2D plane perpendicular to normal."""
    # Find two basis vectors in the plane
    nx, ny, nz = normal
    if abs(nx) < 0.9:
        u = _normalize((1 - nx*nx, -nx*ny, -nx*nz))
    else:
        u = _normalize((-ny*nx, 1 - ny*ny, -ny*nz))
    # v = normal x u
    v = (
        normal[1]*u[2] - normal[2]*u[1],
        normal[2]*u[0] - normal[0]*u[2],
        normal[0]*u[1] - normal[1]*u[0],
    )
    return [(_dot(pt, u), _dot(pt, v)) for pt in verts]


def _normalize(v: tuple) -> tuple:
    mag = math.sqrt(v[0]**2 + v[1]**2 + v[2]**2)
    if mag < 1e-12:
        return v
    return (v[0]/mag, v[1]/mag, v[2]/mag)


def _polygon_area_2d(verts2d: list) -> float:
    """Shoelace area of 2D polygon."""
    n = len(verts2d)
    area = 0.0
    for i in range(n):
        j = (i + 1) % n
        area += verts2d[i][0] * verts2d[j][1]
        area -= verts2d[j][0] * verts2d[i][1]
    return abs(area) / 2.0


def _clip_polygon_to_halfplane(poly, edge_a, edge_b):
    """Sutherland-Hodgman clip step."""
    if not poly:
        return []
    result = []
    n = len(poly)
    for i in range(n):
        curr = poly[i]
        prev = poly[i - 1]
        inside_curr = _is_inside_halfplane(curr, edge_a, edge_b)
        inside_prev = _is_inside_halfplane(prev, edge_a, edge_b)
        if inside_prev and inside_curr:
            result.append(curr)
        elif inside_prev and not inside_curr:
            result.append(_intersect_edge(prev, curr, edge_a, edge_b))
        elif not inside_prev and inside_curr:
            result.append(_intersect_edge(prev, curr, edge_a, edge_b))
            result.append(curr)
    return result


def _is_inside_halfplane(p, a, b) -> bool:
    return (b[0]-a[0])*(p[1]-a[1]) - (b[1]-a[1])*(p[0]-a[0]) >= 0


def _intersect_edge(p1, p2, a, b):
    dx1, dy1 = p2[0]-p1[0], p2[1]-p1[1]
    dx2, dy2 = b[0]-a[0], b[1]-a[1]
    denom = dx1*dy2 - dy1*dx2
    if abs(denom) < 1e-12:
        return p1
    t = ((a[0]-p1[0])*dy2 - (a[1]-p1[1])*dx2) / denom
    return (p1[0]+t*dx1, p1[1]+t*dy1)


def _sutherland_hodgman(subject: list, clip: list) -> list:
    """Clip subject polygon against clip polygon (both 2D, CCW orientation)."""
    out = list(subject)
    n = len(clip)
    for i in range(n):
        if not out:
            break
        out = _clip_polygon_to_halfplane(out, clip[i], clip[(i+1) % n])
    return out


def _overlap_area(verts_a: list, verts_b: list, normal: tuple) -> float:
    """
    Compute overlap area of two coplanar polygons (projected to plane perpendicular to normal).
    Clips B onto A using Sutherland-Hodgman.
    """
    proj_a = _project_to_plane(verts_a, normal)
    proj_b = _project_to_plane(verts_b, normal)
    clipped = _sutherland_hodgman(proj_b, proj_a)
    if len(clipped) < 3:
        return 0.0
    return _polygon_area_2d(clipped)


# ─── GML parsing helpers ─────────────────────────────────────────────────────

def _build_id_index(root) -> dict:
    index = {}
    for elem in root.iter():
        gid = elem.get(GML_ID)
        if gid:
            index[gid] = elem
    return index


def _extract_polygon_verts(poly_elem) -> Optional[list]:
    ext = poly_elem.find('gml:exterior/gml:LinearRing/gml:posList', NS)
    if ext is not None and ext.text:
        return _parse_poslist(ext.text)
    return None


def _get_surface_verts(surf_elem, id_index: dict) -> Optional[list]:
    """Try lod2MultiSurface, then lod3MultiSurface exterior ring."""
    for lod_tag in ('bldg:lod2MultiSurface', 'bldg:lod3MultiSurface',
                    'nrg3:lod2MultiSurface', 'nrg3:lod3MultiSurface'):
        multi_el = surf_elem.find(lod_tag, NS)
        if multi_el is None:
            continue
        for sm in multi_el.findall('.//gml:surfaceMember', NS):
            href = sm.get(f'{XLINK}href', '')
            if href:
                poly_elem = id_index.get(href.lstrip('#'))
                if poly_elem is not None:
                    v = _extract_polygon_verts(poly_elem)
                    if v:
                        return v
            else:
                poly_el = sm.find('gml:Polygon', NS)
                if poly_el is not None:
                    v = _extract_polygon_verts(poly_el)
                    if v:
                        return v
    return None


def _collect_surfaces(root, id_index: dict) -> list:
    """
    Collect all thermalBoundary surface elements with their geometry.
    Returns list of dicts: {id, elem, verts, normal, centroid, zone_id}.
    """
    surfaces = []
    for tz_wrapper in root.findall('.//nrg3:thermalZone', NS):
        for tz in tz_wrapper.findall('nrg3:ThermalZone', NS):
            zone_id = tz.get(GML_ID, '')
            for tb_wrapper in tz.findall('nrg3:thermalBoundary', NS):
                for surf_child in tb_wrapper:
                    surf_id = surf_child.get(GML_ID, '')
                    if not surf_id:
                        continue
                    verts = _get_surface_verts(surf_child, id_index)
                    if not verts or len(verts) < 3:
                        continue
                    normal = _newell_normal(verts)
                    c = _centroid(verts)
                    surfaces.append({
                        'id': surf_id,
                        'elem': surf_child,
                        'verts': verts,
                        'normal': normal,
                        'centroid': c,
                        'zone_id': zone_id,
                    })
    return surfaces


def _normals_antiparallel(n1: tuple, n2: tuple, tol: float = 0.05) -> bool:
    """True if normals are approximately anti-parallel (dot ≈ -1)."""
    return _dot(n1, n2) < -(1.0 - tol)


def _coplanar(s1: dict, s2: dict, tol: float) -> bool:
    """True if s2's centroid lies on s1's plane within tol, and normals anti-parallel."""
    if not _normals_antiparallel(s1['normal'], s2['normal']):
        return False
    dist = _plane_distance(s1['normal'], s1['centroid'], s2['centroid'])
    return dist <= tol


# ─── Enrichment ──────────────────────────────────────────────────────────────

def _inject_string_attribute(surf_elem, name: str, value: str):
    """Insert gen:stringAttribute into surf_elem (or replace existing)."""
    # Remove existing with same name
    for existing in surf_elem.findall(f'{{{GEN_NS}}}stringAttribute', {}):
        if existing.get('name') == name:
            surf_elem.remove(existing)

    attr_el = etree.SubElement(surf_elem, f'{{{GEN_NS}}}stringAttribute')
    attr_el.set('name', name)
    val_el = etree.SubElement(attr_el, f'{{{GEN_NS}}}value')
    val_el.text = value


def _set_adiabatic(surf_elem, value: bool):
    """Set nrg3:bdgBdrySurfIsAdiabatic."""
    tag = f'{{{NRG3_NS}}}bdgBdrySurfIsAdiabatic'
    existing = surf_elem.find(f'nrg3:bdgBdrySurfIsAdiabatic', NS)
    if existing is not None:
        existing.text = 'true' if value else 'false'
    else:
        el = etree.SubElement(surf_elem, tag)
        el.text = 'true' if value else 'false'


def find_adjacent_pairs(surfaces: list, tol: float = 0.01, min_overlap: float = 0.01) -> list:
    """
    Find coplanar, anti-parallel, overlapping surface pairs from different zones.
    Returns list of (i, j) indices.
    """
    pairs = []
    n = len(surfaces)
    for i in range(n):
        for j in range(i + 1, n):
            s1 = surfaces[i]
            s2 = surfaces[j]
            if s1['zone_id'] == s2['zone_id']:
                continue
            if not _coplanar(s1, s2, tol):
                continue
            area = _overlap_area(s1['verts'], s2['verts'], s1['normal'])
            if area >= min_overlap:
                pairs.append((i, j))
    return pairs


def enrich(input_path: str, output_path: str, tol: float = 0.01):
    """Main enrichment routine."""
    logger.info("Parsing %s", input_path)
    tree = etree.parse(input_path)
    root = tree.getroot()

    id_index = _build_id_index(root)
    surfaces = _collect_surfaces(root, id_index)
    logger.info("Collected %d surfaces across all ThermalZones", len(surfaces))

    pairs = find_adjacent_pairs(surfaces, tol=tol)
    logger.info("Found %d adjacent surface pairs", len(pairs))

    matched = set()
    for i, j in pairs:
        s1, s2 = surfaces[i], surfaces[j]
        _inject_string_attribute(s1['elem'], 'adjacentSurface', s2['id'])
        _inject_string_attribute(s1['elem'], 'adjacentZone', s2['zone_id'])
        _inject_string_attribute(s2['elem'], 'adjacentSurface', s1['id'])
        _inject_string_attribute(s2['elem'], 'adjacentZone', s1['zone_id'])
        matched.add(i)
        matched.add(j)
        logger.debug("Matched %s ↔ %s (zones %s / %s)", s1['id'], s2['id'], s1['zone_id'], s2['zone_id'])

    # Mark unmatched PartyWallSurface as adiabatic
    party_tag = f'{{{NRG3_NS}}}PartyWallSurface'
    bldg_ns = 'http://www.opengis.net/citygml/building/2.0'
    party_bldg_tag = f'{{{bldg_ns}}}PartyWallSurface'

    for idx, s in enumerate(surfaces):
        tag = s['elem'].tag
        is_party = ('PartyWallSurface' in tag)
        if is_party and idx not in matched:
            _set_adiabatic(s['elem'], True)
            logger.debug("Marked unmatched PartyWallSurface %s as adiabatic", s['id'])

    logger.info("Writing enriched GML to %s", output_path)
    tree.write(output_path, xml_declaration=True, encoding='UTF-8', pretty_print=True)
    logger.info("Done. %d pairs matched, %d surfaces annotated.", len(pairs), len(matched))


def main():
    parser = argparse.ArgumentParser(
        description="Enrich CityGML with surface adjacency annotations (gen:stringAttribute)"
    )
    parser.add_argument('--input', required=True, help="Input GML file")
    parser.add_argument('--output', required=True, help="Output enriched GML file")
    parser.add_argument('--tol', type=float, default=0.01,
                        help="Coplanarity tolerance in metres (default 0.01)")
    parser.add_argument('--verbose', '-v', action='store_true')
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format='%(levelname)s: %(message)s',
        stream=sys.stderr,
    )

    enrich(args.input, args.output, tol=args.tol)


if __name__ == '__main__':
    main()
