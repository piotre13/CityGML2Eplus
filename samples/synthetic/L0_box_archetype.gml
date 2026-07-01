<?xml version="1.0" encoding="UTF-8"?>
<!--
  L0_box_archetype.gml
  Parse path : POOR  (no ThermalZone)
  Geometry   : LoD1 bounding box (10 x 8 x 6 m – 2-storey residential)
  EnergyADE  : Building-level attributes only (function, year, constructionWeight)
  Tests      : _parse_poor_building() LoD1 fallback, archetype CSV lookup
               → expected archetype row: residential / 1975-1991 / medium
                 u_wall=0.8  u_roof=0.6  u_ground=0.6  u_window=2.5  g=0.6
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <gml:description>Synthetic test dataset – L0: minimal LoD1 box, archetype constructions</gml:description>
  <gml:name>L0 Box Archetype</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 6</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <core:cityObjectMember>
    <bldg:Building gml:id="id_L0_building">
      <gml:description>L0 – simple residential box, LoD1 only, no EnergyADE constructions</gml:description>
      <gml:name>L0 Residential Box</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <!-- Building-level EnergyADE reference point -->
      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 3</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <!-- Building classification -->
      <bldg:class codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_class.xml">habitation</bldg:class>
      <bldg:function codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml">residential</bldg:function>
      <bldg:yearOfConstruction>1975</bldg:yearOfConstruction>
      <bldg:roofType codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_roofType.xml">flat roof</bldg:roofType>
      <bldg:measuredHeight uom="m">6</bldg:measuredHeight>
      <bldg:storeysAboveGround>2</bldg:storeysAboveGround>
      <bldg:storeysBelowGround>0</bldg:storeysBelowGround>
      <bldg:storeyHeightsAboveGround uom="m">3</bldg:storeyHeightsAboveGround>

      <!-- EnergyADE building-level attributes (no constructions, no ThermalZone) -->
      <!-- Parser uses these for archetype table lookup -->
      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">medium</nrg3:bdgConstructionWeight>

      <!-- QualifiedArea at building level (informational) -->
      <nrg3:area>
        <nrg3:QualifiedArea>
          <nrg3:description>Gross floor area of the whole building</nrg3:description>
          <nrg3:source>design drawings</nrg3:source>
          <nrg3:value uom="m^2">160</nrg3:value>
          <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
        </nrg3:QualifiedArea>
      </nrg3:area>
      <nrg3:area>
        <nrg3:QualifiedArea>
          <nrg3:description>Energy reference area (heated floor area)</nrg3:description>
          <nrg3:source>design drawings</nrg3:source>
          <nrg3:value uom="m^2">148</nrg3:value>
          <nrg3:type codeSpace="area_codeSpace">energyReferenceArea</nrg3:type>
        </nrg3:QualifiedArea>
      </nrg3:area>

      <!-- LoD1 solid: 10 x 8 x 6 m bounding box -->
      <!-- Vertices are CCW when viewed from outside (outward normal) -->
      <bldg:lod1Solid>
        <gml:Solid gml:id="id_L0_lod1_solid" srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:exterior>
            <gml:CompositeSurface gml:id="id_L0_lod1_compsurf">

              <!-- Ground face (z=0, normal pointing down) -->
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L0_poly_ground">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 8 0 10 8 0 10 0 0 0 0 0 0 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>

              <!-- South wall (y=0, normal pointing south/-y) -->
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L0_poly_south">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 0 0 10 0 0 10 0 6 0 0 6 0 0 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>

              <!-- North wall (y=8, normal pointing north/+y) -->
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L0_poly_north">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>10 8 0 0 8 0 0 8 6 10 8 6 10 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>

              <!-- East wall (x=10, normal pointing east/+x) -->
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L0_poly_east">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>10 0 0 10 8 0 10 8 6 10 0 6 10 0 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>

              <!-- West wall (x=0, normal pointing west/-x) -->
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L0_poly_west">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 8 0 0 0 0 0 0 6 0 8 6 0 8 0</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>

              <!-- Roof face (z=6, normal pointing up) -->
              <gml:surfaceMember>
                <gml:Polygon gml:id="id_L0_poly_roof">
                  <gml:exterior>
                    <gml:LinearRing>
                      <gml:posList>0 0 6 10 0 6 10 8 6 0 8 6 0 0 6</gml:posList>
                    </gml:LinearRing>
                  </gml:exterior>
                </gml:Polygon>
              </gml:surfaceMember>

            </gml:CompositeSurface>
          </gml:exterior>
        </gml:Solid>
      </bldg:lod1Solid>

    </bldg:Building>
  </core:cityObjectMember>

</core:CityModel>
