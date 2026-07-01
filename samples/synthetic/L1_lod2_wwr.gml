<?xml version="1.0" encoding="UTF-8"?>
<!--
  L1_lod2_wwr.gml
  Parse path : POOR  (no ThermalZone)
  Geometry   : LoD2 thematic surfaces (bldg:boundedBy) – 10 x 8 x 3 m residential
  EnergyADE  : Surface-level attributes – WWR, azimuth, inclination, sky/ground view factors
               bdgConstructionWeight on building; no explicit constructions → archetype
  Tests      : _parse_poor_building() with real LoD2 geometry
               WWR placeholder windows (bdgBdrySurfOpeningToSurfaceRatio)
               Surface metadata attributes (azimuth, inclination, view factors)
               → expected archetype row: residential / 1985 → 1975-1991 / heavy
                 u_wall=0.7  u_roof=0.5  u_ground=0.5  u_window=2.5  g=0.6
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <gml:description>Synthetic test dataset – L1: LoD2 surfaces with WWR and view factors</gml:description>
  <gml:name>L1 LoD2 WWR</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 3</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <core:cityObjectMember>
    <bldg:Building gml:id="id_L1_building">
      <gml:description>L1 – residential LoD2 building with WWR annotations</gml:description>
      <gml:name>L1 Residential LoD2</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 1.5</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <bldg:class codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_class.xml">habitation</bldg:class>
      <bldg:function codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml">residential</bldg:function>
      <bldg:yearOfConstruction>1985</bldg:yearOfConstruction>
      <bldg:roofType>flat roof</bldg:roofType>
      <bldg:measuredHeight uom="m">3</bldg:measuredHeight>
      <bldg:storeysAboveGround>1</bldg:storeysAboveGround>

      <!-- EnergyADE building attributes -->
      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">heavy</nrg3:bdgConstructionWeight>

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

      <!-- LoD2 thematic surfaces -->

      <!-- Ground surface (z=0) -->
      <bldg:boundedBy>
        <bldg:GroundSurface gml:id="id_L1_ground">
          <gml:name>Ground (L1)</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 0</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <bldg:lod2MultiSurface>
            <gml:MultiSurface gml:id="id_L1_ground_geom" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L1_poly_ground">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 8 0 10 8 0 10 0 0 0 0 0 0 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <!-- Ground: azimuth=-1 (horizontal), inclination=180° (facing down) -->
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">1</nrg3:bdgBdrySurfGroundViewFactor>
          <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0</nrg3:bdgBdrySurfSkyViewFactor>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
          <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
        </bldg:GroundSurface>
      </bldg:boundedBy>

      <!-- Roof surface (z=3, flat) -->
      <bldg:boundedBy>
        <bldg:RoofSurface gml:id="id_L1_roof">
          <gml:name>Roof (L1)</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 3</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <bldg:lod2MultiSurface>
            <gml:MultiSurface gml:id="id_L1_roof_geom" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L1_poly_roof">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 0 3 10 0 3 10 8 3 0 8 3 0 0 3</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>
            </gml:MultiSurface>
          </bldg:lod2MultiSurface>
          <!-- Flat roof: azimuth=-1, inclination=0° (facing up) -->
          <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
          <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
          <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0</nrg3:bdgBdrySurfGroundViewFactor>
          <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">1</nrg3:bdgBdrySurfSkyViewFactor>
          <nrg3:bdgBdrySurfHeatCapacity uom="kJ/(m^2*K)">80</nrg3:bdgBdrySurfHeatCapacity>
          <nrg3:bdgBdrySurfThickness uom="mm">280</nrg3:bdgBdrySurfThickness>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
          <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
        </bldg:RoofSurface>
      </bldg:boundedBy>

      <!-- South wall (y=0, azimuth=180°) – higher WWR (main facade) -->
      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L1_wall_south">
          <gml:name>South Wall (L1)</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 0 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <bldg:lod2MultiSurface>
            <gml:MultiSurface gml:id="id_L1_wall_south_geom" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L1_poly_south">
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
          <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
          <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
          <nrg3:bdgBdrySurfHeatCapacity uom="kJ/(m^2*K)">120</nrg3:bdgBdrySurfHeatCapacity>
          <nrg3:bdgBdrySurfThickness uom="mm">310</nrg3:bdgBdrySurfThickness>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <!-- 25% window-to-wall ratio on south facade -->
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.25</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
          <nrg3:bdgBdrySurfOpaqueSurfaceArea uom="m^2">22.5</nrg3:bdgBdrySurfOpaqueSurfaceArea>
          <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <!-- North wall (y=8, azimuth=0°) -->
      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L1_wall_north">
          <gml:name>North Wall (L1)</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 8 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <bldg:lod2MultiSurface>
            <gml:MultiSurface gml:id="id_L1_wall_north_geom" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L1_poly_north">
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
          <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
          <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <!-- 10% WWR on north facade -->
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.10</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
          <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <!-- East wall (x=10, azimuth=90°) -->
      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L1_wall_east">
          <gml:name>East Wall (L1)</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>10 4 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <bldg:lod2MultiSurface>
            <gml:MultiSurface gml:id="id_L1_wall_east_geom" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L1_poly_east">
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
          <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
          <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <!-- 15% WWR on east facade -->
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.15</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
          <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
        </bldg:WallSurface>
      </bldg:boundedBy>

      <!-- West wall (x=0, azimuth=270°) -->
      <bldg:boundedBy>
        <bldg:WallSurface gml:id="id_L1_wall_west">
          <gml:name>West Wall (L1)</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>0 4 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <bldg:lod2MultiSurface>
            <gml:MultiSurface gml:id="id_L1_wall_west_geom" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L1_poly_west">
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
          <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
          <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
          <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
          <!-- 15% WWR on west facade -->
          <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.15</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
          <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
        </bldg:WallSurface>
      </bldg:boundedBy>

    </bldg:Building>
  </core:cityObjectMember>

</core:CityModel>
