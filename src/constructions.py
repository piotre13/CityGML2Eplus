"""
3-tier construction resolver:
  1. Layered  — nrg3:layer elements present
  2. U-value  — nrg3:uValue only (no layers)
  3. Archetype — no construction data (poor-path buildings)
"""
import hashlib
import logging
from typing import Optional

from .model import Construction, Material, NoMassMaterial, GasMaterial

logger = logging.getLogger(__name__)

NS = {
    'gml': 'http://www.opengis.net/gml',
    'nrg3': 'http://www.citygml.org/ade/energy/3.0',
}


def _txt(elem, tag: str, ns=NS) -> Optional[str]:
    child = elem.find(tag, ns)
    return child.text.strip() if child is not None and child.text else None


def _ftxt(elem, tag: str, ns=NS) -> Optional[float]:
    t = _txt(elem, tag, ns)
    return float(t) if t is not None else None


def _content_hash(obj: dict) -> str:
    key = str(sorted(obj.items()))
    return hashlib.md5(key.encode()).hexdigest()[:12]


def resolve_layered_construction(
    constr_id: str,
    constr_elem,
    id_index: dict,
) -> tuple:
    """
    Returns (Construction, {mat_id: Material|NoMassMaterial|GasMaterial}).
    Handles both Gas and SolidMaterial layers.
    """
    layer_elems = constr_elem.findall('nrg3:layer/nrg3:Layer', NS)
    if not layer_elems:
        return None, {}

    materials = {}
    layers = []  # (material_id, thickness_m)

    for layer_el in layer_elems:
        thickness_txt = _txt(layer_el, 'nrg3:thickness')
        thickness_m = float(thickness_txt) / 1000.0 if thickness_txt else 0.0

        mat_ref_el = layer_el.find('nrg3:material', NS)
        if mat_ref_el is None:
            continue
        href = mat_ref_el.get('{http://www.w3.org/1999/xlink}href', '')
        mat_id = href.lstrip('#')

        mat_elem = id_index.get(mat_id)
        if mat_elem is None:
            logger.warning("Material '%s' not found in index; skipping layer", mat_id)
            continue

        tag = mat_elem.tag.split('}')[-1] if '}' in mat_elem.tag else mat_elem.tag

        if tag == 'SolidMaterial':
            cond = _ftxt(mat_elem, 'nrg3:thermalConductivity')
            dens = _ftxt(mat_elem, 'nrg3:density')
            sh = _ftxt(mat_elem, 'nrg3:specificHeatCapacity')
            if sh is not None and sh < 10.0:
                logger.warning(
                    "SolidMaterial '%s' specificHeatCapacity=%.4f appears to be in kJ/(kg·K) "
                    "(EnergyPlus requires J/(kg·K) ≥ 100); multiplying by 1000 → %.1f",
                    mat_id, sh, sh * 1000,
                )
                sh = sh * 1000.0
            mat = Material(
                id=mat_id,
                conductivity=cond or 1.0,
                density=dens or 1000.0,
                specific_heat=sh or 900.0,
                thickness=thickness_m,
            )
            materials[mat_id] = mat

        elif tag == 'Gas':
            gas_type_txt = _txt(mat_elem, 'nrg3:type') or 'Air'
            mat = GasMaterial(id=mat_id, thickness=thickness_m, gas_type=gas_type_txt)
            materials[mat_id] = mat

        else:
            logger.warning("Unknown material element <%s> for id '%s'; skipping", tag, mat_id)
            continue

        layers.append((mat_id, thickness_m))

    if not layers:
        return None, {}

    constr = Construction(
        id=constr_id,
        kind='opaque',
        layers=layers,
    )
    return constr, materials


def resolve_uvalue_construction(
    constr_id: str,
    constr_elem,
    is_glazing: bool = False,
) -> tuple:
    """
    Returns (Construction, {mat_id: NoMassMaterial}).
    For glazings → Construction.kind='glazing', no material dict (handled by idf_writer directly).
    """
    u = _ftxt(constr_elem, 'nrg3:uValue')
    if u is None:
        return None, {}

    g_val = _ftxt(constr_elem, 'nrg3:gValue')

    vis_t = None
    for t_el in constr_elem.findall('nrg3:transmittance/nrg3:Transmittance', NS):
        wl = _txt(t_el, 'nrg3:wavelengthRange')
        if wl and 'visible' in wl.lower():
            vis_t = _ftxt(t_el, 'nrg3:fraction')

    if g_val is None:
        solar_t = None
        for t_el in constr_elem.findall('nrg3:transmittance/nrg3:Transmittance', NS):
            wl = _txt(t_el, 'nrg3:wavelengthRange')
            if wl and 'solar' in wl.lower():
                solar_t = _ftxt(t_el, 'nrg3:fraction')
        if solar_t is not None:
            g_val = solar_t

    if is_glazing:
        constr = Construction(
            id=constr_id,
            kind='glazing',
            u=u,
            g=g_val or 0.6,
            visible_transmittance=vis_t,
        )
        return constr, {}

    # Opaque U-value → NoMassMaterial
    r_val = 1.0 / u if u > 0 else 1.0
    mat_id = f"nomass_{constr_id}"
    mat = NoMassMaterial(id=mat_id, r_value=r_val)
    constr = Construction(
        id=constr_id,
        kind='opaque',
        layers=[(mat_id, r_val)],
        u=u,
    )
    return constr, {mat_id: mat}


def resolve_construction(
    constr_id: str,
    id_index: dict,
    is_glazing: bool = False,
) -> tuple:
    """
    Main entry point: resolve a construction by ID from the global element index.
    Returns (Construction | None, {mat_id: Material|...}).
    Handles LayeredConstruction, ReverseLayeredConstruction, and U-value-only constructions.
    """
    constr_elem = id_index.get(constr_id)
    if constr_elem is None:
        logger.warning("Construction '%s' not found in index", constr_id)
        return None, {}

    tag = constr_elem.tag.split('}')[-1] if '}' in constr_elem.tag else constr_elem.tag

    # ReverseLayeredConstruction — resolve base and reverse layer order
    if tag == 'ReverseLayeredConstruction':
        base_el = constr_elem.find('nrg3:baseLayeredConstruction', NS)
        if base_el is None:
            logger.warning("ReverseLayeredConstruction '%s' has no baseLayeredConstruction", constr_id)
            return None, {}
        href = base_el.get('{http://www.w3.org/1999/xlink}href', '').lstrip('#')
        if not href:
            logger.warning("ReverseLayeredConstruction '%s' baseLayeredConstruction has no href", constr_id)
            return None, {}
        base_constr, base_mats = resolve_construction(href, id_index, is_glazing=is_glazing)
        if base_constr is None:
            return None, {}
        # Reverse the layer order and create a new Construction with this id
        reversed_constr = Construction(
            id=constr_id,
            kind=base_constr.kind,
            layers=list(reversed(base_constr.layers)),
            u=base_constr.u,
            g=base_constr.g,
            visible_transmittance=base_constr.visible_transmittance,
        )
        return reversed_constr, base_mats

    # Tier 1: layered
    layer_elems = constr_elem.findall('nrg3:layer', NS)
    if layer_elems:
        return resolve_layered_construction(constr_id, constr_elem, id_index)

    # Tier 2: U-value
    u_el = constr_elem.find('nrg3:uValue', NS)
    if u_el is not None:
        return resolve_uvalue_construction(constr_id, constr_elem, is_glazing=is_glazing)

    logger.warning("Construction '%s' (tag=%s) has neither layers nor uValue", constr_id, tag)
    return None, {}


def archetype_constructions(
    bldg_id: str,
    archetype_row: dict,
) -> tuple:
    """
    Tier 3: Build constructions from archetype U-values.
    Returns (constructions_dict, materials_dict) — one per surface type + glazing.
    """
    constructions = {}
    materials = {}

    def _make_opaque(suffix, u_val):
        cid = f"arch_{bldg_id}_{suffix}"
        mid = f"nomass_{cid}"
        r = 1.0 / u_val if u_val > 0 else 1.0
        materials[mid] = NoMassMaterial(id=mid, r_value=r)
        constructions[cid] = Construction(
            id=cid, kind='opaque',
            layers=[(mid, r)], u=u_val,
        )
        return cid

    def _make_glazing(suffix, u_val, g_val):
        cid = f"arch_{bldg_id}_{suffix}"
        constructions[cid] = Construction(
            id=cid, kind='glazing',
            u=u_val, g=g_val,
        )
        return cid

    wall_cid = _make_opaque('wall', archetype_row['u_wall'])
    roof_cid = _make_opaque('roof', archetype_row['u_roof'])
    ground_cid = _make_opaque('ground', archetype_row['u_ground'])
    win_cid = _make_glazing('window', archetype_row['u_window'], archetype_row['g_window'])

    type_map = {
        'wall': wall_cid,
        'roof': roof_cid,
        'ground': ground_cid,
        'floor': ground_cid,
        'interior': wall_cid,
        'party': wall_cid,
        'window': win_cid,
    }

    return constructions, materials, type_map
