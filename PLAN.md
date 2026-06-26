# CityGML 2.0 + EnergyADE 3.0 → EnergyPlus 26.1 IDF Converter — Build Plan

> Self-contained spec for a fresh session. No re-exploration needed — all verified data facts, decisions, module layout, and verification steps are below. Start at **§10 Execution order**.

## 0. Goal

Generic, modular converter: read CityGML 2.0 + EnergyADE 3.0 GML (`samples/`, Alderaan dataset) → emit **one minimal-valid EnergyPlus 26.1 IDF per building** containing geometry (zones, walls/roofs/ground, windows), constructions, glazings.

**Hard requirement — detail-agnostic:** same code path handles a building whether constructions are (A) full layered materials, (B) U-value only, or (C) nothing but an archetype code needing a static default table. **Scope stops at geometry + constructions + glazings.** No HVAC/loads/schedules.

## 1. Locked decisions (already agreed with user)

| Topic | Decision |
|-------|----------|
| Stack | **Python + lxml + direct-text IDF** (no eppy/geomeppy). Plain f-string templates. |
| Archetype table | **Scaffold `data/archetypes.csv` now** (placeholder U-values) behind a loader that also accepts `.xlsx`. Runnable end-to-end immediately; swap real Excel later, no code change. |
| Output | **Minimal valid runnable IDF** — include `Version`, `SimulationControl`, `Building`, `GlobalGeometryRules`, `Site:Location` placeholder, `Zone` + the requested geometry/construction objects. Opens/validates in E+ 26.1. No loads/HVAC/schedules. |
| Adjacency | **Separate, fully decoupled script** `enrich_adjacency.py` that surface-matches and **writes adjacency back into the GML** (so it can be lifted into another repo). Converter reads injected attrs if present, else falls back. |
| Rules | Simple, efficient, fast. Don't overcomplicate what's straightforward. |

## 2. Verified data facts (from samples — trust these)

- Root: `core:CityModel > core:cityObjectMember > bldg:Building`.
- Namespaces in samples: `gml=http://www.opengis.net/gml`, `bldg=http://www.opengis.net/citygml/building/2.0`, `core=http://www.opengis.net/citygml/2.0`, **Energy ADE prefix is `nrg3` = `http://www.citygml.org/ade/energy/3.0`** (NOT `energy`), `gen=http://www.opengis.net/citygml/generics/2.0`, `xlink=http://www.w3.org/1999/xlink`.
- **Zone** = `nrg3:ThermalZone` (`gml:id="id_thermal_zone_N"`), child of Building via `nrg3:thermalZone`. Holds a list of `nrg3:thermalBoundary`. (`All.gml` has ~48 buildings / one thermal zone each.)
- **Surface** = each `nrg3:thermalBoundary` wraps `bldg:WallSurface | bldg:RoofSurface | bldg:GroundSurface` containing:
  - `nrg3:layeredConstruction xlink:href="#id_layered_construction_..."`
  - `nrg3:bdgBdrySurfIsAdiabatic` (bool), `nrg3:bdgBdrySurfAzimuth`, `nrg3:bdgBdrySurfInclination`, `nrg3:bdgBdrySurfTotalSurfaceArea`, `nrg3:bdgBdrySurfOpaqueSurfaceArea`, `nrg3:bdgBdrySurfOpeningToSurfaceRatio`
  - `bldg:lod2MultiSurface` → `gml:MultiSurface > gml:surfaceMember xlink:href="#id_building_N_polygon_M"` (clean polygon, **no hole**)
  - `bldg:lod3MultiSurface` → inline `gml:Polygon` with `gml:exterior/gml:LinearRing/gml:posList` **and** `gml:interior/gml:LinearRing/gml:posList` (= window hole)
- **Fenestration** = `bldg:opening > bldg:Window` (`gml:id="..._thermal_opening_K"`) with own `bldg:lod3MultiSurface` polygon + `nrg3:layeredConstruction xlink:href` (glazing) + `nrg3:bdgOpnArea/Azimuth/Inclination`. **Use LoD2 outer ring for the base surface, the Window polygon for E+ `FenestrationSurface:Detailed`** (E+ cuts the hole; ignore the interior ring).
- **Constructions** — `nrg3:LayeredConstruction gml:id="..."`:
  - Layered: `nrg3:layer > nrg3:Layer (gml:id) > nrg3:thickness uom="mm"` + `nrg3:material xlink:href="id_solid_material_X"` → resolves to `nrg3:SolidMaterial` with `nrg3:thermalConductivity uom="W/(K*m)"`, `nrg3:density uom="kg/m^3"`, `nrg3:specificHeatCapacity uom="J/(kg*K)"`. `nrg3:Gas` layers also possible.
  - U-value only: just `nrg3:uValue uom="W/(K*m^2)"` (+ optional `nrg3:gValue`, `nrg3:glazingRatio uom="unit interval"`, optical `nrg3:Transmittance/Reflectance/Emissivity` with `fraction`/`surface`/`wavelengthRange`).
  - Libraries: `nrg3:MaterialLibrary` / `nrg3:LayeredConstructionLibrary` with `nrg3:libraryMember`. Inline in `All.gml`; separate `Alderaan_Energy_ADE_Material_Layered_Construction_Libraries.gml` for the split Core variants. **Material xlink may have no `#` and may be cross-file** — build a global id index.
- **Core.gml** (poor path) buildings: NO thermal zones / constructions. Have `bldg:function` (codeSpace, e.g. "residential building"), `bldg:yearOfConstruction` (e.g. 1955), `bldg:class`, `bldg:measuredHeight`, `bldg:storeysAboveGround`, `bldg:roofType`, `nrg3:bdgConstructionWeight` (heavy/medium/light/veryLight), `nrg3:bdgType` (terracedHouse…), `nrg3:bdgArea/QualifiedArea`, LoD1/LoD2 hull via `bldg:boundedBy` (WallSurface/RoofSurface/GroundSurface → `bldg:lod2MultiSurface`). → **archetype tier C**.
- **Coords**: `srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109"` (RD New, metres), `srsDimension="3"`. `gml:posList` = space-separated `X Y Z` triplets, ring **closed** (first vertex repeated at end). Values synthetic/small (env 0–70 X, −30–15 Y, 0–15 Z). Translate to local origin regardless.
- **No inter-zone adjacency links** in data. Party walls = `nrg3:PartyWallSurface`. `bdgBdrySurfIsAdiabatic` flag present.
- **Data caveat:** sample `specificHeatCapacity` ≈ `0.9` (unphysical, real ~900) and several material props are placeholders — convert **verbatim**, log a warning, do not silently "correct".

Example posLists (building 1, after dropping closing dup): ground `0 0 0 / 0 10 0 / 10 10 0 / 10 0 0`; a wall `0 0 0 / 10 0 0 / 10 0 10 / 5 0 15 / 0 0 10`.

## 3. Module layout

```
src/
  model.py            # intermediate dataclasses (THE abstraction seam)
  parse_gml.py        # lxml -> intermediate model; rich AND poor inputs
  geometry.py         # posList -> verts; local origin; close-strip; outward normal
  constructions.py    # 3-tier resolver (layered | uValue | archetype)
  archetypes.py       # loader csv|xlsx -> lookup(function, year, weight)
  idf_writer.py       # intermediate model -> IDF text (E+ 26.1 objects)
  main.py             # CLI; one IDF per building
  enrich_adjacency.py # STANDALONE preprocessor (gml -> enriched gml), decoupled
data/
  archetypes.csv      # scaffolded starter table (placeholder U-values, marked TODO)
outputs/              # generated IDFs land here
```

## 4. Intermediate model (`model.py`)

`parse_gml` normalizes both rich and poor inputs into this; `idf_writer` only sees this.

```python
BuildingModel(id, name, origin_xyz, zones[], constructions{id->Construction}, materials{id->Material})
Zone(id, name, surfaces[])
Surface(id, stype{wall|roof|ground|floor|interior}, verts[(x,y,z)], constr_id,
        boundary{outdoors|ground|adiabatic|surface}, adj_surface_id, openings[])
Opening(id, verts, constr_id)                       # window
Construction(id, kind{opaque|glazing}, layers[(material_id, thickness_m)], u, g, optical)
Material(id, conductivity, density, specific_heat, thickness)  # or NoMassMaterial(id, r)
```

## 5. Parsing (`parse_gml.py`)

- Accept **one or more** GML files (main + optional `--libraries`). Build a single `gml:id -> element` index across all files so any `xlink:href` (with/without `#`, same/cross file) resolves. Use `lxml.etree`, a prefix→URI nsmap, and `findall` with explicit namespaces (do NOT rely on default-ns hacks).
- Per Building: has `nrg3:thermalZone`? → **rich path** (zones=thermal zones, surfaces=thermalBoundary, openings=windows). Else → **poor path** (one zone per building from `bldg:boundedBy`; openings from `glazingRatio`/`bdgBdrySurfOpeningToSurfaceRatio` as WWR if present, else none).
- Geometry per surface: prefer LoD2 polygon (resolve xlink), fall back to LoD3 exterior ring.
- Construction: resolve `nrg3:layeredConstruction/@xlink:href` → construction id.
- Boundary condition: read `bdgBdrySurfIsAdiabatic`; read adjacency attrs injected by §8 if present; else default by type (wall→outdoors, roof→outdoors, ground→ground, PartyWallSurface→adiabatic).

## 6. Geometry (`geometry.py`)

- `parse_poslist(text, dim=3)` → `[(x,y,z), ...]`; **drop the closing duplicate vertex**; strip `gml:interior` rings for base surfaces.
- Local **origin** = min corner over all building vertices (or building reference point); subtract from every vertex. Store on model.
- `orient_outward(verts, inside_ref)` — Newell normal; flip vertex order if it points toward zone interior so E+ outward normals are correct under `GlobalGeometryRules ... Counterclockwise`. Use zone centroid (or `bdgBdrySurfInclination`+`Azimuth`) as reference.

## 7. Constructions — 3-tier resolver (`constructions.py`)

Resolve each referenced construction id in priority order:
1. **Layered** (`nrg3:layer` present): one E+ `Material` per `SolidMaterial` (Thickness=mm/1000, Conductivity, Density, SpecificHeat; Roughness=`MediumRough`) + a `Construction` listing layers **outside→inside** (assume list order = outside→inside — expose a reverse flag). `Gas` → `Material:AirGap` for opaque.
2. **U-value only** (`nrg3:uValue`, no layers): opaque → `Material:NoMass` with `Thermal Resistance = 1/U` wrapped in `Construction` (note: ignores film split — acceptable V1, add IDF comment). Glazing (`glazingRatio` present or referenced by a Window) → `WindowMaterial:SimpleGlazingSystem` (UFactor=uValue, SHGC=`gValue` or derived from solar `Transmittance`, optional VisibleTransmittance) + `Construction`.
3. **Archetype** (no construction, poor path): `archetypes.lookup(function, yearOfConstruction, constructionWeight)` → per-surface-type U + window U/g → build via tier-2 path. Missing key → nearest/default row + warning.

De-duplicate emitted materials/constructions by content hash (shared library items written once).

## 8. Adjacency enrichment — standalone (`enrich_adjacency.py`)

**Fully decoupled** (own CLI, imports nothing from the converter) so it lifts into another repo. `gml-in → enriched gml-out`:
- Collect every boundary-surface polygon (LoD2 resolved) across all ThermalZones / buildings.
- Match pairs **coplanar + overlapping** (anti-parallel normals, plane distance < tol, projected-area overlap) → shared interior/party walls.
- Write match **back into the GML** on each matched surface as `gen:` attributes (schema-permissive):
  `gen:stringAttribute name="adjacentZone"` (peer ThermalZone gml:id), `gen:stringAttribute name="adjacentSurface"` (peer surface gml:id). Unmatched neighbour / `PartyWallSurface` → set `bdgBdrySurfIsAdiabatic=true`.
- `parse_gml.py` reads them: `adjacentSurface` → E+ `Outside Boundary Condition = Surface` + `OutsideBoundaryConditionObject` = paired surface name; else adiabatic/outdoors. **Converter runs with or without enrichment having been applied.**
- CLI: `python -m src.enrich_adjacency --input X.gml --output X_enriched.gml --tol 0.01`.

## 9. IDF writer (`idf_writer.py`) — E+ 26.1, minimal valid

Per building, emit in order: `Version,26.1;` · `SimulationControl` · `Building` · `GlobalGeometryRules` (StartingVertexPosition=`UpperLeftCorner`, VertexEntryDirection=`Counterclockwise`, CoordinateSystem=`World`) · `Site:Location` placeholder · one `Zone` per zone (origin 0,0,0) · materials (`Material` / `Material:NoMass` / `WindowMaterial:SimpleGlazingSystem`) · `Construction` · `BuildingSurface:Detailed` (Outside Boundary Condition per §5/§8; world-coord vertices) · `FenestrationSurface:Detailed` (BuildingSurfaceName=parent). One small helper per object type. No IDD dependency.

## 10. Execution order (build in this sequence)

1. `model.py` — dataclasses.
2. `geometry.py` — posList parse, origin, orient. Unit-test on the example posLists in §2.
3. `archetypes.py` + `data/archetypes.csv` — loader + seed rows (cols: `function,vintage_min,vintage_max,weight,u_wall,u_roof,u_ground,u_window,g_window`; residential rows by vintage band × weight, placeholder U-values marked TODO; lazy `openpyxl` for `.xlsx`).
4. `constructions.py` — 3-tier resolver.
5. `parse_gml.py` — rich + poor paths, cross-file id index.
6. `idf_writer.py` — IDF templates.
7. `main.py` — CLI orchestration, one IDF per building.
8. `enrich_adjacency.py` — standalone, last (independent of the rest).

CLI:
```
python -m src.main --input samples/Alderaan_Energy_ADE_All.gml \
    [--libraries samples/Alderaan_Energy_ADE_Material_Layered_Construction_Libraries.gml ...] \
    [--archetypes data/archetypes.csv] [--outdir outputs] [--lod 2|3]
# -> outputs/id_building_1.idf, id_building_2.idf, ...
```
Deps: `lxml` (required), `openpyxl` (only if reading `.xlsx`).

## 11. Verification

1. **Rich path:** run on `Alderaan_Energy_ADE_All.gml` → ~48 IDFs, each with Zone(s), Material/Construction, BuildingSurface:Detailed (walls/roof/ground), FenestrationSurface:Detailed (windows). Spot-check `id_building_1.idf` vertices vs §2 example posLists.
2. **Poor path:** run on `Alderaan_Energy_ADE_Core.gml` → IDFs with archetype-derived constructions (warnings logged), LoD2-hull geometry, no/empty windows.
3. **Split-file:** run a `Core_Building_physics*` file with `--libraries ..._Libraries.gml`; confirm cross-file xlink material resolution.
4. **Validity:** if EnergyPlus 26.1 present, `energyplus -r id_building_1.idf` (or IDFVersionUpdater/parse) loads without geometry/construction errors. Else assert: every Construction referenced by a surface exists; every Material in a Construction exists; object counts sane.
5. **Enrichment:** run `enrich_adjacency` on `All.gml`, diff for injected `adjacentSurface` attrs on interior/party walls, re-run converter, confirm those surfaces become `Surface` boundary with valid paired names.

## 12. Out of scope (V1)

HVAC, internal loads, schedules, occupancy, DHW, infiltration objects, weather/RunPeriod beyond placeholder, multi-zone airflow, shading from neighbouring buildings.
