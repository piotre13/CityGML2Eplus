"""
IDF writer for EnergyPlus 26.1 — minimal valid IDF from BuildingModel.

GlobalGeometryRules: UpperLeftCorner, Counterclockwise, World.
"""
import logging
import os
from typing import IO

from .model import BuildingModel, Construction, Material, NoMassMaterial, GasMaterial
from .geometry import simplify_to_quad

logger = logging.getLogger(__name__)

_ROUGHNESS = 'MediumRough'


def _verts_to_idf(verts: list, indent: str = '    ') -> str:
    """Format vertex list for BuildingSurface:Detailed / FenestrationSurface:Detailed."""
    lines = []
    for i, (x, y, z) in enumerate(verts):
        sep = ',' if i < len(verts) - 1 else ';'
        lines.append(f"{indent}{x:.6f}, {y:.6f}, {z:.6f}{sep}")
    return '\n'.join(lines)


def _write_header(f: IO, bldg: BuildingModel):
    f.write(f"Version,26.1;\n\n")
    f.write(
        "SimulationControl,\n"
        "    No,                      !- Do Zone Sizing Calculation\n"
        "    No,                      !- Do System Sizing Calculation\n"
        "    No,                      !- Do Plant Sizing Calculation\n"
        "    Yes,                     !- Run Simulation for Sizing Periods\n"
        "    Yes;                     !- Run Simulation for Weather File Run Periods\n\n"
    )
    f.write(
        "SizingPeriod:DesignDay,\n"
        "    Placeholder Summer Design Day,  !- Name\n"
        "    7,                       !- Month\n"
        "    21,                      !- Day of Month\n"
        "    SummerDesignDay,         !- Day Type\n"
        "    30,                      !- Maximum Dry-Bulb Temperature {C}\n"
        "    10,                      !- Daily Dry-Bulb Temperature Range {delta-C}\n"
        "    DefaultMultipliers,      !- Dry-Bulb Temperature Range Modifier Type\n"
        "    ,                        !- Dry-Bulb Temperature Range Modifier Day Schedule Name\n"
        "    Wetbulb,                 !- Humidity Condition Type\n"
        "    20,                      !- Wetbulb or DewPoint at Maximum Dry-Bulb {C}\n"
        "    ,                        !- Humidity Condition Day Schedule Name\n"
        "    ,                        !- Humidity Ratio at Maximum Dry-Bulb {kgWater/kgDryAir}\n"
        "    ,                        !- Enthalpy at Maximum Dry-Bulb {J/kg}\n"
        "    ,                        !- Daily Wet-Bulb Temperature Range {delta-C}\n"
        "    101325,                  !- Barometric Pressure {Pa}\n"
        "    3,                       !- Wind Speed {m/s}\n"
        "    0,                       !- Wind Direction {deg}\n"
        "    No,                      !- Rain Indicator\n"
        "    No,                      !- Snow Indicator\n"
        "    No;                      !- Daylight Saving Time Indicator\n\n"
    )
    f.write(
        "RunPeriod,\n"
        "    Annual,                  !- Name\n"
        "    1,                       !- Begin Month\n"
        "    1,                       !- Begin Day of Month\n"
        "    ,                        !- Begin Year\n"
        "    12,                      !- End Month\n"
        "    31,                      !- End Day of Month\n"
        "    ,                        !- End Year\n"
        "    Sunday,                  !- Day of Week for Start Day\n"
        "    Yes,                     !- Use Weather File Holidays and Special Days\n"
        "    Yes,                     !- Use Weather File DST Period\n"
        "    Yes,                     !- Apply Weekend Holiday Rule\n"
        "    Yes,                     !- Use Weather File Rain Indicators\n"
        "    Yes;                     !- Use Weather File Snow Indicators\n\n"
    )
    f.write(
        "Timestep,4;\n\n"
    )
    safe_name = bldg.name.replace(',', ' ').replace(';', ' ')[:100]
    f.write(
        f"Building,\n"
        f"    {safe_name},            !- Name\n"
        f"    0.0,                    !- North Axis {{deg}}\n"
        f"    City,                   !- Terrain\n"
        f"    0.04,                   !- Loads Convergence Tolerance Value\n"
        f"    0.4,                    !- Temperature Convergence Tolerance Value\n"
        f"    FullInteriorAndExterior,!- Solar Distribution\n"
        f"    25,                     !- Maximum Number of Warmup Days\n"
        f"    6;                      !- Minimum Number of Warmup Days\n\n"
    )
    f.write(
        "GlobalGeometryRules,\n"
        "    UpperLeftCorner,         !- Starting Vertex Position\n"
        "    Counterclockwise,        !- Vertex Entry Direction\n"
        "    World;                   !- Coordinate System\n\n"
    )
    f.write(
        "Site:Location,\n"
        "    Placeholder,             !- Name\n"
        "    52.37,                   !- Latitude {deg}\n"
        "    4.90,                    !- Longitude {deg}\n"
        "    1.0,                     !- Time Zone {hr}\n"
        "    0.0;                     !- Elevation {m}\n\n"
    )
    f.write(
        "ScheduleTypeLimits,\n"
        "    Any Number;              !- Name\n\n"
        "Schedule:Constant,\n"
        "    DualSetpointSched,       !- Name\n"
        "    Any Number,              !- Schedule Type Limits Name\n"
        "    4;                       !- Hourly Value (4=DualSetpoint)\n\n"
        "Schedule:Constant,\n"
        "    HeatingSetpointSched,    !- Name\n"
        "    Any Number,              !- Schedule Type Limits Name\n"
        "    20;                      !- Heating Setpoint {C}\n\n"
        "Schedule:Constant,\n"
        "    CoolingSetpointSched,    !- Name\n"
        "    Any Number,              !- Schedule Type Limits Name\n"
        "    26;                      !- Cooling Setpoint {C}\n\n"
    )


def _write_zone(f: IO, zone_id: str, zone_name: str):
    safe = zone_name.replace(',', ' ').replace(';', ' ')[:100]
    f.write(
        f"Zone,\n"
        f"    {zone_id},              !- Name\n"
        f"    0.0,                    !- Direction of Relative North {{deg}}\n"
        f"    0.0, 0.0, 0.0,          !- X, Y, Z Origin {{m}}\n"
        f"    1,                      !- Type\n"
        f"    1,                      !- Multiplier\n"
        f"    AutoCalculate,          !- Ceiling Height {{m}}\n"
        f"    AutoCalculate;          !- Volume {{m3}}\n\n"
    )


def _write_material(f: IO, mat):
    if isinstance(mat, Material):
        f.write(
            f"Material,\n"
            f"    {mat.id},\n"
            f"    {_ROUGHNESS},           !- Roughness\n"
            f"    {mat.thickness:.6f},    !- Thickness {{m}}\n"
            f"    {mat.conductivity:.6f}, !- Conductivity {{W/m-K}}\n"
            f"    {mat.density:.3f},      !- Density {{kg/m3}}\n"
            f"    {mat.specific_heat:.3f}; !- Specific Heat {{J/kg-K}}\n\n"
        )
    elif isinstance(mat, NoMassMaterial):
        f.write(
            f"Material:NoMass,\n"
            f"    {mat.id},\n"
            f"    {_ROUGHNESS},           !- Roughness\n"
            f"    {mat.r_value:.6f};      !- Thermal Resistance {{m2-K/W}}\n"
            f"    ! Note: NoMass from U-value only (film resistances not split)\n\n"
        )
    elif isinstance(mat, GasMaterial):
        f.write(
            f"Material:AirGap,\n"
            f"    {mat.id},\n"
            f"    {mat.r_value:.6f};    !- Thermal Resistance {{m2-K/W}}\n\n"
        )


def _write_glazing(f: IO, constr: Construction):
    """Write WindowMaterial:SimpleGlazingSystem for glazing constructions."""
    shgc = constr.g if constr.g is not None else 0.6
    mat_id = f"glazmat_{constr.id}"
    if constr.visible_transmittance is not None:
        f.write(
            f"WindowMaterial:SimpleGlazingSystem,\n"
            f"    {mat_id},\n"
            f"    {constr.u:.4f},          !- U-Factor {{W/m2-K}}\n"
            f"    {shgc:.4f},              !- Solar Heat Gain Coefficient\n"
            f"    {constr.visible_transmittance:.4f}; !- Visible Transmittance\n\n"
        )
    else:
        f.write(
            f"WindowMaterial:SimpleGlazingSystem,\n"
            f"    {mat_id},\n"
            f"    {constr.u:.4f},          !- U-Factor {{W/m2-K}}\n"
            f"    {shgc:.4f};              !- Solar Heat Gain Coefficient\n\n"
        )
    return mat_id


def _write_construction(f: IO, constr: Construction, materials: dict):
    """Write Construction object. Returns glazing mat id if applicable."""
    if constr.kind == 'glazing':
        if constr.u is not None:
            glaz_mat_id = _write_glazing(f, constr)
            f.write(
                f"Construction,\n"
                f"    {constr.id},\n"
                f"    {glaz_mat_id};\n\n"
            )
        return

    # Opaque
    layer_ids = [mat_id for mat_id, _ in constr.layers]
    if not layer_ids:
        logger.warning("Construction %s has no layers; skipping", constr.id)
        return

    lines = [f"Construction,", f"    {constr.id},"]
    for i, mat_id in enumerate(layer_ids):
        sep = ',' if i < len(layer_ids) - 1 else ';'
        # For Material objects, use thickness from construction layer, not from material default
        lines.append(f"    {mat_id}{sep}")
    f.write('\n'.join(lines) + '\n\n')


def _surface_type_eplus(stype: str) -> str:
    mapping = {
        'wall': 'Wall',
        'roof': 'Roof',
        'ground': 'Floor',
        'floor': 'Floor',
        'interior': 'Wall',
        'party': 'Wall',
    }
    return mapping.get(stype, 'Wall')


def _boundary_eplus(boundary: str, adj_surf_id: str = None) -> tuple:
    """Returns (OutsideBoundaryCondition, OutsideBoundaryConditionObject, SunExposure, WindExposure)."""
    if boundary == 'outdoors':
        return 'Outdoors', '', 'SunExposed', 'WindExposed'
    if boundary == 'ground':
        return 'Ground', '', 'NoSun', 'NoWind'
    if boundary == 'adiabatic':
        return 'Adiabatic', '', 'NoSun', 'NoWind'
    if boundary == 'surface' and adj_surf_id:
        return 'Surface', adj_surf_id, 'NoSun', 'NoWind'
    return 'Outdoors', '', 'SunExposed', 'WindExposed'


def _write_building_surface(f: IO, surf, zone_id: str, bldg: BuildingModel):
    if len(surf.verts) < 3:
        logger.warning("Surface %s has <3 vertices; skipping", surf.id)
        return

    surf_type = _surface_type_eplus(surf.stype)
    obc, obc_obj, sun, wind = _boundary_eplus(surf.boundary, surf.adj_surface_id)
    constr_id = surf.constr_id or 'DefaultConstruction'
    n_verts = len(surf.verts)

    f.write(f"BuildingSurface:Detailed,\n")
    f.write(f"    {surf.id},           !- Name\n")
    f.write(f"    {surf_type},         !- Surface Type\n")
    f.write(f"    {constr_id},         !- Construction Name\n")
    f.write(f"    {zone_id},           !- Zone Name\n")
    f.write(f"    ,                    !- Space Name\n")
    f.write(f"    {obc},               !- Outside Boundary Condition\n")
    if obc_obj:
        f.write(f"    {obc_obj},           !- Outside Boundary Condition Object\n")
    else:
        f.write(f"    ,                    !- Outside Boundary Condition Object\n")
    f.write(f"    {sun},               !- Sun Exposure\n")
    f.write(f"    {wind},              !- Wind Exposure\n")
    f.write(f"    AutoCalculate,       !- View Factor to Ground\n")
    f.write(f"    {n_verts},           !- Number of Vertices\n")
    f.write(_verts_to_idf(surf.verts) + '\n\n')


def _write_fenestration_surface(f: IO, opening, parent_surf_id: str, zone_id: str):
    if not opening.verts or len(opening.verts) < 3:
        return  # WWR-based opening with no explicit geometry — skip
    constr_id = opening.constr_id or 'DefaultGlazingConstruction'
    # E+ FenestrationSurface:Detailed max 4 vertices — simplify if needed
    verts = simplify_to_quad(opening.verts)
    n_verts = len(verts)

    f.write(f"FenestrationSurface:Detailed,\n")
    f.write(f"    {opening.id},        !- Name\n")
    f.write(f"    Window,              !- Surface Type\n")
    f.write(f"    {constr_id},         !- Construction Name\n")
    f.write(f"    {parent_surf_id},    !- Building Surface Name\n")
    f.write(f"    ,                    !- Outside Boundary Condition Object\n")
    f.write(f"    AutoCalculate,       !- View Factor to Ground\n")
    f.write(f"    ,                    !- Frame and Divider Name\n")
    f.write(f"    1,                   !- Multiplier\n")
    f.write(f"    {n_verts},           !- Number of Vertices\n")
    f.write(_verts_to_idf(verts) + '\n\n')




def _write_zone_hvac(f: IO, zone_id: str):
    """Write IdealLoadsAirSystem + thermostat for one zone."""
    s = zone_id[:60]
    f.write(
        f"ThermostatSetpoint:DualSetpoint,\n"
        f"    {s}_DualSP,\n"
        f"    HeatingSetpointSched,    !- Heating Setpoint Temperature Schedule Name\n"
        f"    CoolingSetpointSched;    !- Cooling Setpoint Temperature Schedule Name\n\n"
    )
    f.write(
        f"ZoneControl:Thermostat,\n"
        f"    {s}_Tstat,\n"
        f"    {zone_id},               !- Zone or ZoneList Name\n"
        f"    DualSetpointSched,       !- Control Type Schedule Name\n"
        f"    ThermostatSetpoint:DualSetpoint,\n"
        f"    {s}_DualSP;              !- Control Name\n\n"
    )
    f.write(
        f"ZoneHVAC:IdealLoadsAirSystem,\n"
        f"    {s}_IdealLoads,\n"
        f"    ,                        !- Availability Schedule Name\n"
        f"    {s}_SupplyIn,            !- Zone Supply Air Node Name\n"
        f"    {s}_ExhNode,             !- Zone Exhaust Air Node Name\n"
        f"    ,                        !- System Inlet Air Node Name\n"
        f"    50,                      !- Maximum Heating Supply Air Temperature {{C}}\n"
        f"    13,                      !- Minimum Cooling Supply Air Temperature {{C}}\n"
        f"    0.0156,                  !- Maximum Heating Supply Air Humidity Ratio\n"
        f"    0.0077,                  !- Minimum Cooling Supply Air Humidity Ratio\n"
        f"    NoLimit,                 !- Heating Limit\n"
        f"    ,                        !- Maximum Heating Air Flow Rate {{m3/s}}\n"
        f"    ,                        !- Maximum Sensible Heating Capacity {{W}}\n"
        f"    NoLimit,                 !- Cooling Limit\n"
        f"    ,                        !- Maximum Cooling Air Flow Rate {{m3/s}}\n"
        f"    ,                        !- Maximum Total Cooling Capacity {{W}}\n"
        f"    ,                        !- Heating Availability Schedule Name\n"
        f"    ,                        !- Cooling Availability Schedule Name\n"
        f"    ConstantSensibleHeatRatio, !- Dehumidification Control Type\n"
        f"    0.7,                     !- Cooling Sensible Heat Ratio\n"
        f"    None,                    !- Humidification Control Type\n"
        f"    ,                        !- Design Specification Outdoor Air Object Name\n"
        f"    ,                        !- Outdoor Air Inlet Node Name\n"
        f"    ,                        !- Demand Controlled Ventilation Type\n"
        f"    ,                        !- Outdoor Air Economizer Type\n"
        f"    ,                        !- Heat Recovery Type\n"
        f"    ,                        !- Sensible Heat Recovery Effectiveness\n"
        f"    ;                        !- Latent Heat Recovery Effectiveness\n\n"
    )
    f.write(
        f"ZoneHVAC:EquipmentList,\n"
        f"    {s}_EquipList,\n"
        f"    SequentialLoad,          !- Load Distribution Scheme\n"
        f"    ZoneHVAC:IdealLoadsAirSystem,\n"
        f"    {s}_IdealLoads,\n"
        f"    1,                       !- Zone Equipment Cooling Sequence\n"
        f"    1,                       !- Zone Equipment Heating or No-Load Sequence\n"
        f"    ,\n"
        f"    ;\n\n"
    )
    f.write(
        f"ZoneHVAC:EquipmentConnections,\n"
        f"    {zone_id},               !- Zone Name\n"
        f"    {s}_EquipList,           !- Zone Conditioning Equipment List Name\n"
        f"    {s}_SupplyIn,            !- Zone Air Inlet Node or NodeList Name\n"
        f"    {s}_ExhNode,             !- Zone Air Exhaust Node or NodeList Name\n"
        f"    {s}_AirNode,             !- Zone Air Node Name\n"
        f"    {s}_RetNode;             !- Zone Return Air Node or NodeList Name\n\n"
    )


def _write_outputs(f: IO):
    f.write(
        "Output:VariableDictionary,IDF;\n\n"
        "Output:Variable,*,Zone Mean Air Temperature,Hourly;\n"
        "Output:Variable,*,Zone Ideal Loads Zone Total Heating Energy,Hourly;\n"
        "Output:Variable,*,Zone Ideal Loads Zone Total Cooling Energy,Hourly;\n"
        "Output:Variable,*,Zone Ideal Loads Supply Air Temperature,Hourly;\n\n"
    )


def write_idf(bldg: BuildingModel, outdir: str):
    """Write one IDF file per building to outdir/{bldg.id}.idf"""
    os.makedirs(outdir, exist_ok=True)
    path = os.path.join(outdir, f"{bldg.id}.idf")

    with open(path, 'w', encoding='utf-8') as f:
        _write_header(f, bldg)

        # Zones + HVAC
        for zone in bldg.zones:
            _write_zone(f, zone.id, zone.name)
            _write_zone_hvac(f, zone.id)

        # Materials (deduplicated — same id written once)
        written_mats = set()
        for mat_id, mat in bldg.materials.items():
            if mat_id not in written_mats:
                _write_material(f, mat)
                written_mats.add(mat_id)

        # Constructions
        written_constrs = set()
        for constr_id, constr in bldg.constructions.items():
            if constr_id not in written_constrs:
                _write_construction(f, constr, bldg.materials)
                written_constrs.add(constr_id)

        # Building surfaces + fenestration
        for zone in bldg.zones:
            for surf in zone.surfaces:
                _write_building_surface(f, surf, zone.id, bldg)
                for opening in surf.openings:
                    _write_fenestration_surface(f, opening, surf.id, zone.id)

        _write_outputs(f)

    logger.info("Wrote %s", path)
    return path
