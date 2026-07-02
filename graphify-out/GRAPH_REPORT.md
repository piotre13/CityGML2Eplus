# Graph Report - .  (2026-07-02)

## Corpus Check
- Corpus is ~9,467 words - fits in a single context window. You may not need a graph.

## Summary
- 169 nodes · 388 edges · 11 communities
- Extraction: 93% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 25 edges (avg confidence: 0.89)
- Token cost: 150,668 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Adjacency Enrichment Script|Adjacency Enrichment Script]]
- [[_COMMUNITY_IDF Writer & V1 Scope|IDF Writer & V1 Scope]]
- [[_COMMUNITY_Archetype Table & Docs|Archetype Table & Docs]]
- [[_COMMUNITY_Construction Resolver|Construction Resolver]]
- [[_COMMUNITY_GML Geometry Extraction|GML Geometry Extraction]]
- [[_COMMUNITY_Building & Boundary Parsing|Building & Boundary Parsing]]
- [[_COMMUNITY_GML Parsing & UsageZone|GML Parsing & UsageZone]]
- [[_COMMUNITY_Geometry Utilities|Geometry Utilities]]
- [[_COMMUNITY_Building Data Model|Building Data Model]]
- [[_COMMUNITY_GML Parse Path Strategies|GML Parse Path Strategies]]

## God Nodes (most connected - your core abstractions)
1. `_parse_rich_building()` - 19 edges
2. `_parse_poor_building()` - 17 edges
3. `_parse_coincides_building()` - 17 edges
4. `write_idf()` - 15 edges
5. `Construction` - 15 edges
6. `ArchetypeTable` - 13 edges
7. `PLAN.md — CityGML2EPlus Converter Build Plan` - 13 edges
8. `BuildingModel` - 12 edges
9. `README.md — CityGML2EPlus` - 12 edges
10. `resolve_construction()` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Known limitation: ground temperatures not set (E+ default 18C)` --references--> `_write_header()`  [INFERRED]
  README.md → src/idf_writer.py
- `Known limitation: SizingPeriod:DesignDay entries are stubs` --references--> `_write_header()`  [INFERRED]
  README.md → src/idf_writer.py
- `V1 out-of-scope: HVAC/loads/schedules (per PLAN.md)` --conceptually_related_to--> `_write_zone_hvac()`  [INFERRED]
  PLAN.md → src/idf_writer.py
- `Rich parse path (ThermalZone + inline ThermalBoundary present)` --references--> `_parse_rich_building()`  [INFERRED]
  PLAN.md → src/parse_gml.py
- `Poor parse path (no EnergyADE data)` --references--> `_parse_poor_building()`  [INFERRED]
  PLAN.md → src/parse_gml.py

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Core conversion pipeline: GML parse -> intermediate model -> IDF write** — src_parse_gml_parse_gml, src_model, src_idf_writer_write_idf [EXTRACTED 1.00]
- **3-tier construction resolver dispatch chain** — src_constructions_resolve_construction, src_constructions_archetype_constructions, src_archetypes_archetypetable_lookup [INFERRED 0.95]
- **PLAN Sec.10 module build execution order** — src_model, src_geometry, src_archetypes, src_constructions, src_parse_gml, src_idf_writer, src_main, src_enrich_adjacency [EXTRACTED 1.00]

## Communities (11 total, 0 thin omitted)

### Community 0 - "Adjacency Enrichment Script"
Cohesion: 0.08
Nodes (41): Adjacency enrichment mechanism (coplanar+overlap surface matching), Adjacency decision: decoupled standalone script, _build_id_index(), _centroid(), _clip_polygon_to_halfplane(), _collect_surfaces(), _coplanar(), _dot() (+33 more)

### Community 1 - "IDF Writer & V1 Scope"
Cohesion: 0.11
Nodes (30): eppy (rejected IDF library), geomeppy (rejected IDF library), Known limitation: ground temperatures not set (E+ default 18C), Known limitation: Site:Location hardcoded placeholder, Known limitation: SizingPeriod:DesignDay entries are stubs, Output decision: minimal valid runnable IDF (V1 scope stop), Stack decision: Python + lxml + direct-text IDF, V1 out-of-scope: HVAC/loads/schedules (per PLAN.md) (+22 more)

### Community 2 - "Archetype Table & Docs"
Cohesion: 0.18
Nodes (14): Alderaan sample dataset, Archetype table decision: scaffold CSV now, swap Excel later, archetypes.csv schema per PLAN.md (function,vintage_min,vintage_max,weight,u_wall,u_roof,u_ground,u_window,g_window), archetypes.csv schema per README.md (use_type,period,u_wall,u_roof,u_floor,u_window) — verified NOT present in actual data/archetypes.csv header or src/archetypes.py column names, CityGML 2.0, EnergyADE 3.0, EnergyPlus 26.1, Known limitation: archetype CSV ships as placeholder data (+6 more)

### Community 3 - "Construction Resolver"
Cohesion: 0.22
Nodes (19): Detail-agnostic hard requirement, Intermediate model / abstraction seam (BuildingModel), 3-tier construction resolver (layered / uValue / archetype), archetype_constructions(), _content_hash(), _ftxt(), 3-tier construction resolver:   1. Layered  — nrg3:layer elements present   2. U, Returns (Construction, {mat_id: NoMassMaterial}).     For glazings → Constructio (+11 more)

### Community 4 - "GML Geometry Extraction"
Cohesion: 0.18
Nodes (13): geometry.py responsibility per PLAN.md: posList parse, local origin, outward-normal orientation, parse_poslist(), Parse gml:posList text → list of (x,y,z) tuples; drop closing duplicate vertex., _extract_lod1_surfaces(), _extract_polygon_verts(), _get_surface_verts(), _get_window_verts(), Extract window polygon vertices (LoD3 exterior ring). (+5 more)

### Community 5 - "Building & Boundary Parsing"
Cohesion: 0.23
Nodes (13): centroid(), compute_origin(), orient_outward(), Ensure Newell normal points away from inside_ref (zone centroid).     E+ GlobalG, min corner (x, y, z) over all vertex lists., translate_verts(), _boundary_condition(), _parse_coincides_building() (+5 more)

### Community 6 - "GML Parsing & UsageZone"
Cohesion: 0.24
Nodes (9): Known limitation: UsageZone schedules parsed but not written to IDF, EnergyADE UsageZone (occupancy/gains/HVAC-hours schedules), build_id_index(), _ftxt(), parse_gml(), Parse CityGML 2.0 + EnergyADE 3.0 GML files into BuildingModel list.  Rich path, Build gml:id → element dict across all parsed trees., Parse one or more GML files → list of BuildingModel.     main_file: path to main (+1 more)

### Community 7 - "Geometry Utilities"
Cohesion: 0.36
Nodes (7): geometry.py responsibility per README.md: 'Polygon simplification utilities', _dot3(), newell_normal(), _normalize3(), Newell's method normal (unit vector)., Reduce polygon to ≤4 vertices by computing the bounding rectangle     in the pol, simplify_to_quad()

### Community 8 - "Building Data Model"
Cohesion: 0.53
Nodes (6): BuildingModel, Opening, Surface, Zone, _parse_poor_building(), Parse building without thermalZone (poor path) — one zone, archetype constructio

### Community 9 - "GML Parse Path Strategies"
Cohesion: 1.00
Nodes (3): Coincides-hull parse path (coincidesWithLod2/3Hull flag), Poor parse path (no EnergyADE data), Rich parse path (ThermalZone + inline ThermalBoundary present)

## Ambiguous Edges - Review These
- `parse_gml.py` → `Known limitation: UsageZone schedules parsed but not written to IDF`  [AMBIGUOUS]
  README.md · relation: conceptually_related_to

## Knowledge Gaps
- **7 isolated node(s):** `eppy (rejected IDF library)`, `geomeppy (rejected IDF library)`, `EnergyADE UsageZone (occupancy/gains/HVAC-hours schedules)`, `Known limitation: Site:Location hardcoded placeholder`, `Known limitation: SizingPeriod:DesignDay entries are stubs` (+2 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `parse_gml.py` and `Known limitation: UsageZone schedules parsed but not written to IDF`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **Why does `PLAN.md — CityGML2EPlus Converter Build Plan` connect `Archetype Table & Docs` to `Adjacency Enrichment Script`, `IDF Writer & V1 Scope`, `Construction Resolver`, `GML Parsing & UsageZone`, `Geometry Utilities`?**
  _High betweenness centrality (0.177) - this node is a cross-community bridge._
- **Why does `README.md — CityGML2EPlus` connect `Archetype Table & Docs` to `Adjacency Enrichment Script`, `IDF Writer & V1 Scope`, `Construction Resolver`, `GML Parsing & UsageZone`, `Geometry Utilities`?**
  _High betweenness centrality (0.165) - this node is a cross-community bridge._
- **Why does `_boundary_condition()` connect `Building & Boundary Parsing` to `Adjacency Enrichment Script`, `Building Data Model`, `GML Parsing & UsageZone`?**
  _High betweenness centrality (0.095) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `_parse_rich_building()` (e.g. with `Rich parse path (ThermalZone + inline ThermalBoundary present)` and `resolve_construction()`) actually correct?**
  _`_parse_rich_building()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `3-tier construction resolver:   1. Layered  — nrg3:layer elements present   2. U`, `Returns (Construction, {mat_id: Material|NoMassMaterial|GasMaterial}).     Handl`, `Returns (Construction, {mat_id: NoMassMaterial}).     For glazings → Constructio` to the rest of the system?**
  _56 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Adjacency Enrichment Script` be split into smaller, more focused modules?**
  _Cohesion score 0.08013937282229965 - nodes in this community are weakly interconnected._