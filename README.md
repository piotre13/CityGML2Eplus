# CityGML2EPlus

Converts **CityGML 2.0 + EnergyADE 3.0** city models to **EnergyPlus 26.1** IDF files. One IDF per building.

---

## Requirements

- Python 3.10+
- `lxml`
- EnergyPlus 26.1 (for simulation only)

```bash
pip install lxml
```

---

## Quick Start

```bash
python -m src.main \
    --input samples/Alderaan_Energy_ADE_All.gml \
    --outdir outputs/myrun
```

Writes one `.idf` per building to `outputs/myrun/`.

---

## CLI Reference

```
python -m src.main [OPTIONS]

Required:
  --input FILE            Main GML file

Optional:
  --libraries FILE [...]  Additional GML files for cross-file xlink resolution
  --archetypes FILE       Archetype CSV (default: data/archetypes.csv)
  --outdir DIR            Output directory (default: outputs)
  --lod {2,3}             Preferred LoD for surface geometry (default: 2)
  --verbose, -v           Debug logging
```

---

## Running EnergyPlus

```bash
energyplus \
    -w data/testweather.epw \
    -d outputs/myrun/run_bldg1 \
    outputs/myrun/id_building_1.idf
```

Use a TMY3/EPW weather file matching your city. Results land in the `-d` directory.

**Batch run all buildings:**

```bash
EPW=data/testweather.epw
for idf in outputs/myrun/*.idf; do
    name=$(basename "$idf" .idf)
    energyplus -w "$EPW" -d "outputs/myrun/${name}_out" "$idf"
done
```

---

## Parse Paths

The converter chooses geometry and construction source per building:

| Path | Triggered when | Geometry source | Constructions |
|------|---------------|-----------------|---------------|
| **rich** | EnergyADE `ThermalZone` + inline `ThermalBoundary` present | ADE boundary polygons | ADE `LayeredConstruction` |
| **coincides-hull** | `coincidesWithLod2Hull` or `coincidesWithLod3Hull` flag set | LoD2/3 shell geometry | ADE or archetype |
| **poor** | No EnergyADE data | LoD1 bounding box | Archetype table |

---

## Archetype Table

`data/archetypes.csv` supplies fallback U-values for buildings with no EnergyADE construction data.

Required columns:

| Column | Description |
|--------|-------------|
| `use_type` | Building use class (e.g. `residential`) |
| `period` | Construction period (e.g. `1970-1979`) |
| `u_wall` | Wall U-value [W/m²K] |
| `u_roof` | Roof U-value [W/m²K] |
| `u_floor` | Floor U-value [W/m²K] |
| `u_window` | Window U-value [W/m²K] |

---

## Generated IDF Contents

Each IDF includes:

- `Version 26.1`, `SimulationControl`, `RunPeriod` (annual)
- `Site:Location` (placeholder — override with your city coordinates)
- `SizingPeriod:DesignDay` (placeholder — for sizing runs)
- `Building`, `GlobalGeometryRules`
- One `Zone` per thermal zone
- `BuildingSurface:Detailed` for all opaque surfaces
- `FenestrationSurface:Detailed` for windows (if present in ADE)
- `Construction` + `Material`/`WindowMaterial:SimpleGlazing` from ADE or archetype
- `ZoneHVAC:IdealLoadsAirSystem` with dual-setpoint thermostat (20°C heat / 26°C cool)
- Output variables: zone temperature, heating/cooling energy (hourly)

---

## Project Structure

```
src/
  main.py           # CLI entry point
  parse_gml.py      # CityGML + EnergyADE parser (lxml)
  model.py          # BuildingModel dataclasses
  idf_writer.py     # EnergyPlus IDF serialiser
  constructions.py  # Material/construction mapping
  archetypes.py     # Archetype CSV loader
  geometry.py       # Polygon simplification utilities
  enrich_adjacency.py  # Surface adjacency inference

samples/            # Example GML inputs
data/               # archetypes.csv, weather files
outputs/            # Generated IDFs (git-ignored)
schemas/            # XSD schemas for validation
```

---

## Known Limitations

- `Site:Location` is hardcoded placeholder — update `_write_header` in `idf_writer.py` with actual coordinates.
- `SizingPeriod:DesignDay` entries are stubs — E+ skips them and uses weather file.
- `UsageZone` schedules (occupancy, internal gains, HVAC operating hours) parsed but not yet written to IDF.
- Ground temperatures not set — E+ defaults to 18°C constant.
- Archetype CSV ships as placeholder; populate with TABULA or equivalent national data.
