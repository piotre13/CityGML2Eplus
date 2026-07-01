<?xml version="1.0" encoding="UTF-8"?>
<!--
  L2_coincides_uvalue.gml
  Parse path : COINCIDES  (nrg3:thermalZone present, NO thermalBoundary)
  Geometry   : LoD2 thematic surfaces (bldg:boundedBy) – 10 x 8 x 3 m residential
  EnergyADE  : ThermalZone (coincides with LoD2 hull), ThermalZone attributes,
               U-value LayeredConstructions (for documentation; parser uses archetypes
               for this path), QualifiedArea, QualifiedVolume, infiltrationRate
  Tests      : _parse_coincides_building() path selection
               ThermalZone id used as zone name
               Archetype lookup: residential / 1990 → 1992-2005 / medium
                 u_wall=0.55  u_roof=0.45  u_ground=0.45  u_window=2.0  g=0.6
  Note       : The layeredConstruction elements in the library are valid EnergyADE
               but are NOT used by the coincides path; they document what U-values
               were intended. The rich path (L3+) fully resolves layered constructions.
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <gml:description>Synthetic test dataset – L2: coincides-hull path with U-value constructions</gml:description>
  <gml:name>L2 Coincides U-value</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 3</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <!-- LayeredConstruction library: U-value constructions for documentation -->
  <core:cityObjectMember>
    <nrg3:LayeredConstructionLibrary gml:id="id_L2_lc_library">
      <gml:description>U-value constructions for L2 building (residential, 1990)</gml:description>
      <gml:name>L2 U-value Construction Library</gml:name>
      <nrg3:source>TABULA NL 1990s retrofit</nrg3:source>
      <nrg3:author>Synthetic dataset</nrg3:author>

      <!-- Wall: U=0.55 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L2_lc_wall">
          <gml:description>External wall assembly, U=0.55 W/(m²·K)</gml:description>
          <gml:name>L2 Wall Construction (U-value)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.55</nrg3:uValue>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.9</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Roof: U=0.45 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L2_lc_roof">
          <gml:description>Flat roof assembly, U=0.45 W/(m²·K)</gml:description>
          <gml:name>L2 Roof Construction (U-value)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.45</nrg3:uValue>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Ground: U=0.45 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L2_lc_ground">
          <gml:description>Ground slab assembly, U=0.45 W/(m²·K)</gml:description>
          <gml:name>L2 Ground Construction (U-value)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.45</nrg3:uValue>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Glazing: U=1.4, g=0.6 (double glazing) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L2_lc_glazing">
          <gml:description>Double glazing unit, U=1.4 W/(m²·K), g=0.6</gml:description>
          <gml:name>L2 Window Construction (U-value)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">1.4</nrg3:uValue>
          <nrg3:glazingRatio uom="unit interval">0.9</nrg3:glazingRatio>
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.6</nrg3:fraction>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.74</nrg3:fraction>
              <nrg3:wavelengthRange>visible</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.1</nrg3:fraction>
              <nrg3:surface>inside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.84</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

    </nrg3:LayeredConstructionLibrary>
  </core:cityObjectMember>

  <core:cityObjectMember>
    <bldg:Building gml:id="id_L2_building">
      <gml:description>L2 – residential LoD2 building with coinciding ThermalZone</gml:description>
      <gml:name>L2 Residential Coincides</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 1.5</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <bldg:function codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml">residential</bldg:function>
      <bldg:yearOfConstruction>1990</bldg:yearOfConstruction>
      <bldg:measuredHeight uom="m">3</bldg:measuredHeight>
      <bldg:storeysAboveGround>1</bldg:storeysAboveGround>

      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">medium</nrg3:bdgConstructionWeight>

      <!-- LoD2 geometry (used by coincides path for surface extraction) -->
      <bldg:boundedBy>
        <bldg:GroundSurface gml:id="id_L2_ground">
          <bldg:lod2MultiSurface>
            <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L2_poly_ground">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 8 0 10 8 0 10 0 0 0 0 0 0 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
        </bldg:GroundSurface>
      </bldg:boundedBy>

      <bldg:boundedBy>
        <bldg:RoofSurface gml:id="id_L2_roof">
          <bldg:lod2MultiSurface>
            <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L2_poly_roof">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 0 3 10 0 3 10 8 3 0 8 3 0 0 3</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
        </bldg:RoofSurface>
      </bldg:boundedBy>

      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L2_wall_south">
          <bldg:lod2MultiSurface>
            <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L2_poly_south">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 0 0 10 0 0 10 0 3 0 0 3 0 0 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">180</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.25</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L2_wall_north">
          <bldg:lod2MultiSurface>
            <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L2_poly_north">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>10 8 0 0 8 0 0 8 3 10 8 3 10 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.10</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L2_wall_east">
          <bldg:lod2MultiSurface>
            <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L2_poly_east">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>10 0 0 10 8 0 10 8 3 10 0 3 10 0 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.12</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L2_wall_west">
          <bldg:lod2MultiSurface>
            <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L2_poly_west">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 8 0 0 0 0 0 0 3 0 8 3 0 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">270</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.12</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <!-- ThermalZone coincides with LoD2 hull (no thermalBoundary children) -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L2_tz1">
          <gml:description>Thermal zone coinciding with LoD2 building hull</gml:description>
          <gml:name>L2 ThermalZone</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>

          <!-- Qualified areas -->
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">80</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">73</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">netFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">73</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">energyReferenceArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>

          <!-- Qualified volumes -->
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">240</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">219</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">netVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>

          <!-- ThermalZone physics attributes -->
          <nrg3:heatCapacity uom="J/K">180000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.6</nrg3:infiltrationRate>
          <nrg3:isCooled>false</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <!-- Flag: this zone coincides with the LoD2 hull -->
          <nrg3:coincidesWithLod2Hull>true</nrg3:coincidesWithLod2Hull>
          <nrg3:coincidesWithLod3Hull>false</nrg3:coincidesWithLod3Hull>
          <!-- No thermalBoundary children → coincides path in parser -->
        </nrg3:ThermalZone>
      </nrg3:thermalZone>

    </bldg:Building>
  </core:cityObjectMember>

</core:CityModel>
