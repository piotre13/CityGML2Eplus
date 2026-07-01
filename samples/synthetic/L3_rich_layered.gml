<?xml version="1.0" encoding="UTF-8"?>
<!--
  L3_rich_layered.gml
  Parse path : RICH  (nrg3:thermalZone + nrg3:thermalBoundary)
  Geometry   : LoD2 thermalBoundary surfaces – 10 x 8 x 3 m residential
  EnergyADE  : Full layered constructions with SolidMaterial (λ/ρ/Cp/porosity/permeance)
               Gas layer (air gap), ReverseLayeredConstruction
               ThermalZone attributes: infiltrationRate, heatCapacity, isHeated/isCooled
  Tests      : _parse_rich_building() full flow
               resolve_layered_construction() with SolidMaterial + GasMaterial
               ReverseLayeredConstruction base construction reversal
               No windows in this level
  Wall construction (inside→outside): plaster / brick / EPS insulation / exterior plaster
  Roof construction (inside→outside): interior plaster / concrete / air gap / mineral wool / membrane
  Ground (inside→outside): screed / EPS insulation / concrete
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <gml:description>Synthetic test dataset – L3: rich path with full layered constructions</gml:description>
  <gml:name>L3 Rich Layered Constructions</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 3</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <!-- ================================================================
       Construction and Material Library (inline, no separate file)
       Convention: layers listed from INSIDE to OUTSIDE (EnergyADE 3.0)
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:LayeredConstructionLibrary gml:id="id_L3_lc_library">
      <gml:description>Full layered constructions for L3 residential building (1960s)</gml:description>
      <gml:name>L3 Construction Library</gml:name>
      <nrg3:source>TABULA NL pre-1965 typology</nrg3:source>
      <nrg3:author>Synthetic dataset</nrg3:author>

      <!-- ──────────────────────────────────────────────── MATERIALS ── -->

      <!-- Interior plaster -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L3_mat_int_plaster">
          <!-- Reuse as single-layer construction for quick reference.
               Real material objects are embedded in the layer elements below. -->
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- ──────────────────────────────────────────────── WALLS ── -->

      <!-- External wall: inside→outside
           Layer 1: interior gypsum plaster     15 mm  λ=0.40  ρ=1000  Cp=840
           Layer 2: solid clay brick           240 mm  λ=0.72  ρ=1800  Cp=840
           Layer 3: EPS insulation             80 mm   λ=0.038 ρ=15    Cp=1450
           Layer 4: exterior cement render      20 mm  λ=0.87  ρ=1800  Cp=840
      -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L3_lc_wall">
          <gml:description>External wall: plaster / brick / EPS / render (inside→outside)</gml:description>
          <gml:name>L3 External Wall</gml:name>
          <nrg3:libraryCode codeSpace="lc_library_codeSpace">L3_wall</nrg3:libraryCode>
          <nrg3:uValue uom="W/(K*m^2)">0.35</nrg3:uValue>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.90</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.90</nrg3:fraction>
              <nrg3:surface>inside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.30</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>

          <!-- Layer 1: interior gypsum plaster (inside face) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_wall_layer1">
              <nrg3:thickness uom="mm">15</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_gypsum_plaster">
                  <gml:name>Interior Gypsum Plaster</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.30</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.5e-10</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.24</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.12</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 2: solid clay brick -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_wall_layer2">
              <nrg3:thickness uom="mm">240</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_brick">
                  <gml:name>Solid Clay Brick</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.72</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.18</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">2.0e-11</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.80</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.22</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 3: EPS thermal insulation (added during retrofit) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_wall_layer3">
              <nrg3:thickness uom="mm">80</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_eps">
                  <gml:name>EPS Thermal Insulation</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.038</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">15</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.95</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">5.0e-13</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">23.5</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">2.5</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 4: exterior cement render (outside face) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_wall_layer4">
              <nrg3:thickness uom="mm">20</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_ext_render">
                  <gml:name>Exterior Cement Render</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.87</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.25</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">8.0e-11</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Wall viewed from inside (reversed layer order for interior surfaces) -->
      <nrg3:libraryMember>
        <nrg3:ReverseLayeredConstruction gml:id="id_L3_lc_wall_reverse">
          <gml:description>Reverse of external wall (outside→inside) for surfaces facing inward</gml:description>
          <gml:name>L3 External Wall (reversed)</gml:name>
          <nrg3:baseLayeredConstruction xlink:href="#id_L3_lc_wall"/>
        </nrg3:ReverseLayeredConstruction>
      </nrg3:libraryMember>

      <!-- ──────────────────────────────────────────────── ROOF ── -->

      <!-- Flat roof: inside→outside
           Layer 1: interior plaster     15 mm  λ=0.40  ρ=1000  Cp=840
           Layer 2: reinforced concrete 200 mm  λ=1.70  ρ=2300  Cp=840
           Layer 3: air gap              30 mm  (Gas)
           Layer 4: mineral wool        120 mm  λ=0.035 ρ=30    Cp=840
           Layer 5: bitumen membrane      5 mm  (NoMass, R=0.02)
      -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L3_lc_roof">
          <gml:description>Flat roof: plaster / concrete / air gap / mineral wool / membrane</gml:description>
          <gml:name>L3 Flat Roof</gml:name>
          <nrg3:libraryCode codeSpace="lc_library_codeSpace">L3_roof</nrg3:libraryCode>
          <nrg3:uValue uom="W/(K*m^2)">0.25</nrg3:uValue>

          <!-- Layer 1: interior plaster -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_roof_layer1">
              <nrg3:thickness uom="mm">15</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_plaster_roof">
                  <gml:name>Interior Gypsum Plaster (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.30</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.5e-10</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 2: reinforced concrete slab -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_roof_layer2">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_concrete">
                  <gml:name>Reinforced Concrete</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.05</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.0e-12</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.58</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.13</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 3: enclosed air gap (Gas) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_roof_layer3">
              <nrg3:thickness uom="mm">30</nrg3:thickness>
              <nrg3:material>
                <!-- Gas layer: uses ISO 6946 default R-value for still air cavity -->
                <nrg3:Gas gml:id="id_L3_mat_airgap">
                  <gml:name>Enclosed Air Gap</gml:name>
                  <nrg3:type codeSpace="gas_type_codeSpace">air</nrg3:type>
                  <nrg3:rValue uom="m^2*K/W">0.18</nrg3:rValue>
                  <nrg3:isVentilated>false</nrg3:isVentilated>
                </nrg3:Gas>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 4: mineral wool insulation -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_roof_layer4">
              <nrg3:thickness uom="mm">120</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_mineral_wool">
                  <gml:name>Mineral Wool</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.035</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">30</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.95</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">8.0e-10</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">8.1</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">1.2</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 5: bitumen waterproofing membrane (outside face) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_roof_layer5">
              <nrg3:thickness uom="mm">5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_bitumen">
                  <gml:name>Bitumen Membrane</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.23</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1100</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.01</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.0e-14</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- ──────────────────────────────────────────────── GROUND SLAB ── -->

      <!-- Ground slab: inside→outside
           Layer 1: cement screed        60 mm  λ=1.40  ρ=2000  Cp=840
           Layer 2: EPS floor insulation 80 mm  λ=0.038 ρ=15    Cp=1450
           Layer 3: concrete slab       200 mm  λ=1.70  ρ=2300  Cp=840
      -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L3_lc_ground">
          <gml:description>Ground slab: screed / EPS insulation / concrete (inside→outside)</gml:description>
          <gml:name>L3 Ground Slab</gml:name>
          <nrg3:libraryCode codeSpace="lc_library_codeSpace">L3_ground</nrg3:libraryCode>
          <nrg3:uValue uom="W/(K*m^2)">0.40</nrg3:uValue>

          <!-- Layer 1: cement screed -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_ground_layer1">
              <nrg3:thickness uom="mm">60</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_screed">
                  <gml:name>Cement Screed</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.08</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">5.0e-11</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 2: EPS floor insulation -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_ground_layer2">
              <nrg3:thickness uom="mm">80</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_eps_floor">
                  <gml:name>EPS Floor Insulation</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.038</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">15</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.95</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">5.0e-13</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

          <!-- Layer 3: concrete slab (outside/ground face) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L3_lc_ground_layer3">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L3_mat_concrete_slab">
                  <gml:name>Concrete Ground Slab</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.05</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.0e-12</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>

        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

    </nrg3:LayeredConstructionLibrary>
  </core:cityObjectMember>

  <!-- ================================================================
       Building
       ================================================================ -->
  <core:cityObjectMember>
    <bldg:Building gml:id="id_L3_building">
      <gml:description>L3 – residential LoD2 rich path with full layered constructions</gml:description>
      <gml:name>L3 Residential Rich</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 1.5</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <bldg:function codeSpace="http://www.sig3d.org/codelists/standard/building/2.0/_AbstractBuilding_function.xml">residential</bldg:function>
      <bldg:yearOfConstruction>1960</bldg:yearOfConstruction>
      <bldg:measuredHeight uom="m">3</bldg:measuredHeight>
      <bldg:storeysAboveGround>1</bldg:storeysAboveGround>

      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">heavy</nrg3:bdgConstructionWeight>

      <!-- ────────────────────────────────────────────── THERMAL ZONE ── -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L3_tz1">
          <gml:description>Single heated zone – 10 x 8 x 3 m</gml:description>
          <gml:name>L3 ThermalZone</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>

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
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">240</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>

          <!-- ThermalZone physics -->
          <nrg3:heatCapacity uom="J/K">1500000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.4</nrg3:infiltrationRate>
          <nrg3:isCooled>false</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- ─────────────────────────────── THERMAL BOUNDARIES ── -->

          <!-- Ground surface (z=0) -->
          <nrg3:thermalBoundary>
            <bldg:GroundSurface gml:id="id_L3_tz1_ground">
              <gml:name>Ground (L3)</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>5 4 0</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod2MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L3_poly_ground">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 10 8 0 10 0 0 0 0 0 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod2MultiSurface>
              <!-- Construction reference (layers inside→outside) -->
              <nrg3:layeredConstruction xlink:href="#id_L3_lc_ground"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">1</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
              <nrg3:bdgBdrySurfThickness uom="mm">340</nrg3:bdgBdrySurfThickness>
            </bldg:GroundSurface>
          </nrg3:thermalBoundary>

          <!-- Roof surface (z=3) -->
          <nrg3:thermalBoundary>
            <bldg:RoofSurface gml:id="id_L3_tz1_roof">
              <gml:name>Roof (L3)</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>5 4 3</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod2MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L3_poly_roof">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 3 10 0 3 10 8 3 0 8 3 0 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod2MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L3_lc_roof"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">1</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfHeatCapacity uom="kJ/(m^2*K)">100</nrg3:bdgBdrySurfHeatCapacity>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
              <nrg3:bdgBdrySurfThickness uom="mm">370</nrg3:bdgBdrySurfThickness>
            </bldg:RoofSurface>
          </nrg3:thermalBoundary>

          <!-- South wall (y=0, azimuth=180°) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L3_tz1_wall_south">
              <gml:name>South Wall (L3)</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>5 0 1.5</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod2MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L3_poly_south">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 0 10 0 0 10 0 3 0 0 3 0 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod2MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L3_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">180</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfHeatCapacity uom="kJ/(m^2*K)">200</nrg3:bdgBdrySurfHeatCapacity>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
              <nrg3:bdgBdrySurfThickness uom="mm">355</nrg3:bdgBdrySurfThickness>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- North wall (y=8, azimuth=0°) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L3_tz1_wall_north">
              <gml:name>North Wall (L3)</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>5 8 1.5</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod2MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L3_poly_north">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 8 0 0 8 0 0 8 3 10 8 3 10 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod2MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L3_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall (x=10, azimuth=90°) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L3_tz1_wall_east">
              <gml:name>East Wall (L3)</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>10 4 1.5</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod2MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L3_poly_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 0 0 10 8 0 10 8 3 10 0 3 10 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod2MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L3_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall (x=0, azimuth=270°) – uses ReverseLayeredConstruction as example -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L3_tz1_wall_west">
              <gml:name>West Wall (L3) – ReverseLayeredConstruction example</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>0 4 1.5</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod2MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L3_poly_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 0 0 0 0 0 3 0 8 3 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod2MultiSurface>
              <!-- ReverseLayeredConstruction: same assembly as east/south/north walls
                   but layers ordered outside→inside (demonstrates parser handling) -->
              <nrg3:layeredConstruction xlink:href="#id_L3_lc_wall_reverse"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">270</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

        </nrg3:ThermalZone>
      </nrg3:thermalZone>

    </bldg:Building>
  </core:cityObjectMember>

</core:CityModel>
