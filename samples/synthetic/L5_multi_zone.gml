<?xml version="1.0" encoding="UTF-8"?>
<!--
  L5_multi_zone.gml
  Parse path : RICH  (nrg3:thermalZone + nrg3:thermalBoundary)
  Geometry   : LoD3 – 10 × 8 × 6 m two-storey OFFICE (year 2000)
  EnergyADE  : 2 ThermalZones (ground + first floor)
               Intermediate floor pre-annotated adjacency (gen:stringAttribute)
               Party/adiabatic north wall on first-floor zone
               Condensing Boiler (15 kW, naturalGas)
               UtilityNetworkConnection, EnergyPerformanceCertificate
               Per-zone UsageZone + Occupants (5 workers each)
  Tests      : multi-zone adjacency resolution, adiabatic-by-flag, boiler device,
               EPC, UtilityNetworkConnection, per-zone UsageZone with Occupants
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <gml:description>Synthetic test dataset – L5: rich path, 2 zones, boiler, adjacency pre-annotation</gml:description>
  <gml:name>L5 Multi-Zone Office</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 6</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <!-- ================================================================
       Schedule Library
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:ScheduleLibrary gml:id="id_L5_schedule_library">
      <gml:description>Schedules for L5 two-storey office building</gml:description>
      <gml:name>L5 Schedule Library</gml:name>
      <nrg3:source>EN 16798-1 office profile</nrg3:source>

      <!-- Occupancy: idle=0, usage=1, 08:00-18:00 -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L5_occ_sched">
          <gml:description>Occupancy rate: unoccupied (0) / occupied (1) 08:00-18:00</gml:description>
          <gml:name>L5 Occupancy Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="unit interval">0</nrg3:idleValue>
          <nrg3:usageValue uom="unit interval">1</nrg3:usageValue>
          <nrg3:startUsageTime>08:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Heating setpoint: 18°C setback / 21°C occupied -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L5_heat_sched">
          <gml:description>Heating setpoint: 18°C setback / 21°C occupied (08:00-18:00)</gml:description>
          <gml:name>L5 Heating Setpoint Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="degrees Celsius">18</nrg3:idleValue>
          <nrg3:usageValue uom="degrees Celsius">21</nrg3:usageValue>
          <nrg3:startUsageTime>08:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Cooling setpoint: 26°C setback / 24°C occupied -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L5_cool_sched">
          <gml:description>Cooling setpoint: 26°C setback / 24°C occupied</gml:description>
          <gml:name>L5 Cooling Setpoint Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="degrees Celsius">26</nrg3:idleValue>
          <nrg3:usageValue uom="degrees Celsius">24</nrg3:usageValue>
          <nrg3:startUsageTime>08:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Ventilation: off/on -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L5_vent_sched">
          <gml:description>Ventilation availability: off (0) / on (1) 07:30-18:30</gml:description>
          <gml:name>L5 Ventilation Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="unit interval">0</nrg3:idleValue>
          <nrg3:usageValue uom="unit interval">1</nrg3:usageValue>
          <nrg3:startUsageTime>07:30:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:30:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

    </nrg3:ScheduleLibrary>
  </core:cityObjectMember>

  <!-- ================================================================
       Construction Library
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:LayeredConstructionLibrary gml:id="id_L5_lc_library">
      <gml:description>Constructions for L5 two-storey office (year 2000)</gml:description>
      <gml:name>L5 Construction Library</gml:name>

      <!-- External wall: brick + mineral wool, U=0.35 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L5_lc_wall">
          <gml:description>Brick cavity wall with mineral-wool insulation</gml:description>
          <gml:name>L5 External Wall</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.35</nrg3:uValue>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.90</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.35</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <!-- Layer 1: inside render -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_wall_l1">
              <nrg3:thickness uom="mm">10</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_inside_render">
                  <gml:name>Interior Plaster Render</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1600</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 2: solid brick -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_wall_l2">
              <nrg3:thickness uom="mm">220</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_brick">
                  <gml:name>Solid Brick</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.77</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.30</nrg3:porosity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 3: mineral wool insulation -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_wall_l3">
              <nrg3:thickness uom="mm">80</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_mw_wall">
                  <gml:name>Mineral Wool (wall)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.036</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">60</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.95</nrg3:porosity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 4: outside render -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_wall_l4">
              <nrg3:thickness uom="mm">10</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_outside_render">
                  <gml:name>Exterior Render Coat</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1600</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Roof: RC slab + mineral wool, U=0.22 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L5_lc_roof">
          <gml:description>Flat roof: RC slab + mineral wool insulation + screed</gml:description>
          <gml:name>L5 Flat Roof</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.22</nrg3:uValue>
          <!-- Layer 1: gypsum ceiling board (inside) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_roof_l1">
              <nrg3:thickness uom="mm">15</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_gyp_roof">
                  <gml:name>Gypsum Board (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 2: reinforced concrete slab -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_roof_l2">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_rc_roof">
                  <gml:name>Reinforced Concrete (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 3: mineral wool insulation -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_roof_l3">
              <nrg3:thickness uom="mm">150</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_mw_roof">
                  <gml:name>Mineral Wool (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.036</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">60</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 4: screed + waterproof membrane (outside) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_roof_l4">
              <nrg3:thickness uom="mm">50</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_screed_roof">
                  <gml:name>Cement Screed (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Ground slab: RC + EPS + screed, U=0.35 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L5_lc_ground">
          <gml:description>Ground-bearing slab: screed + EPS + concrete</gml:description>
          <gml:name>L5 Ground Slab</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.35</nrg3:uValue>
          <!-- Layer 1: cement screed (inside) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_ground_l1">
              <nrg3:thickness uom="mm">60</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_screed_gnd">
                  <gml:name>Cement Screed (ground)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 2: EPS thermal insulation -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_ground_l2">
              <nrg3:thickness uom="mm">100</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_eps">
                  <gml:name>EPS Floor Insulation</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.035</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">25</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 3: concrete slab (outside/ground) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_ground_l3">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_slab">
                  <gml:name>Concrete Ground Slab</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Interior floor: concrete slab only (no insulation) – between zones -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L5_lc_intfloor">
          <gml:description>Interior intermediate floor slab – no thermal insulation</gml:description>
          <gml:name>L5 Interior Floor Slab</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">3.5</nrg3:uValue>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L5_lc_intfloor_l1">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L5_mat_rc_intfloor">
                  <gml:name>Reinforced Concrete (intermediate floor)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Glazing: U=1.4 W/(m²·K), g-value=0.6, solar τ=0.52 – double glazing -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L5_lc_glazing">
          <gml:description>Standard double glazing: U=1.4, solar τ=0.52</gml:description>
          <gml:name>L5 Double Glazing</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">1.4</nrg3:uValue>
          <nrg3:glazingRatio uom="unit interval">0.90</nrg3:glazingRatio>
          <!-- Solar transmittance (used as g-value proxy) -->
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.52</nrg3:fraction>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <!-- Visible light transmittance -->
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.65</nrg3:fraction>
              <nrg3:wavelengthRange>visible</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <!-- Solar reflectance outside -->
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.20</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <!-- Emissivity outside (clear glass) -->
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

  <!-- ================================================================
       Building
       ================================================================ -->
  <core:cityObjectMember>
    <bldg:Building gml:id="id_L5_building">
      <gml:description>L5 – two-storey office, rich path, multi-zone, boiler, adjacency pre-annotation</gml:description>
      <gml:name>L5 Multi-Zone Office</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 3</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <bldg:function>office</bldg:function>
      <bldg:yearOfConstruction>2000</bldg:yearOfConstruction>
      <bldg:measuredHeight uom="m">6</bldg:measuredHeight>
      <bldg:storeysAboveGround>2</bldg:storeysAboveGround>
      <bldg:storeyHeightsAboveGround uom="m">3</bldg:storeyHeightsAboveGround>

      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">medium</nrg3:bdgConstructionWeight>

      <nrg3:area>
        <nrg3:QualifiedArea>
          <nrg3:value uom="m^2">160</nrg3:value>
          <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
        </nrg3:QualifiedArea>
      </nrg3:area>
      <nrg3:height>
        <nrg3:QualifiedHeight>
          <nrg3:value uom="m">6</nrg3:value>
          <nrg3:type codeSpace="height_codeSpace">measuredHeight</nrg3:type>
        </nrg3:QualifiedHeight>
      </nrg3:height>

      <!-- ───────────────────────── DEVICES ── -->

      <!-- Condensing gas boiler: 15 kW -->
      <nrg3:device>
        <nrg3:Boiler gml:id="id_L5_boiler">
          <gml:name>L5 Condensing Gas Boiler</gml:name>
          <nrg3:installedPower uom="W">15000</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.92</nrg3:nominalEfficiency>
          <nrg3:hasCondensation>true</nrg3:hasCondensation>
          <nrg3:energySource codeSpace="energy_source_codeSpace">naturalGas</nrg3:energySource>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L5_boiler_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">spaceHeating</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L5_heat_sched"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:Boiler>
      </nrg3:device>

      <!-- ───────────────────────── UTILITY NETWORK CONNECTION ── -->

      <nrg3:utilityNetworkConnection>
        <nrg3:UtilityNetworkConnection gml:id="id_L5_gas_conn">
          <nrg3:networkType codeSpace="network_type_codeSpace">naturalGas</nrg3:networkType>
          <nrg3:connectionType codeSpace="connection_type_codeSpace">connected</nrg3:connectionType>
        </nrg3:UtilityNetworkConnection>
      </nrg3:utilityNetworkConnection>

      <!-- ───────────────────────── ENERGY PERFORMANCE CERTIFICATE ── -->

      <nrg3:energyPerformanceCertificate>
        <nrg3:EnergyPerformanceCertificate gml:id="id_L5_epc">
          <nrg3:certificationDate>2010-06-01</nrg3:certificationDate>
          <nrg3:rating codeSpace="epc_rating_codeSpace">C</nrg3:rating>
          <nrg3:value uom="kWh/(m^2*a)">145</nrg3:value>
          <nrg3:validUntilDate>2020-06-01</nrg3:validUntilDate>
        </nrg3:EnergyPerformanceCertificate>
      </nrg3:energyPerformanceCertificate>

      <!-- ───────────────────────── USAGE ZONES ── -->

      <!-- Zone 1 usage zone: ground floor, 5 workers -->
      <nrg3:usageZone>
        <nrg3:UsageZone gml:id="id_L5_uz1">
          <gml:description>Ground-floor office usage zone</gml:description>
          <gml:name>L5 Ground Floor Usage Zone</gml:name>
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
          <nrg3:type codeSpace="usageZone_type_codeSpace">office</nrg3:type>
          <nrg3:occupiedBy>
            <nrg3:Occupants gml:id="id_L5_occupants1">
              <gml:name>L5 Ground Floor Occupants</gml:name>
              <nrg3:type codeSpace="occupants_type_codeSpace">workers</nrg3:type>
              <nrg3:numberOfOccupants>5</nrg3:numberOfOccupants>
              <nrg3:heatDissipation uom="W">80</nrg3:heatDissipation>
              <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.50</nrg3:heatDissipationConvectiveFraction>
              <nrg3:heatDissipationLatentFraction uom="unit interval">0.50</nrg3:heatDissipationLatentFraction>
              <nrg3:heatDissipationRadiantFraction uom="unit interval">0.30</nrg3:heatDissipationRadiantFraction>
              <nrg3:occupancyRate xlink:href="#id_L5_occ_sched"/>
            </nrg3:Occupants>
          </nrg3:occupiedBy>
          <nrg3:internalHeatGains uom="W/m^2">20</nrg3:internalHeatGains>
          <nrg3:heatingSchedule xlink:href="#id_L5_heat_sched"/>
          <nrg3:coolingSchedule xlink:href="#id_L5_cool_sched"/>
          <nrg3:ventilationSchedule xlink:href="#id_L5_vent_sched"/>
        </nrg3:UsageZone>
      </nrg3:usageZone>

      <!-- Zone 2 usage zone: first floor, 5 workers -->
      <nrg3:usageZone>
        <nrg3:UsageZone gml:id="id_L5_uz2">
          <gml:description>First-floor office usage zone</gml:description>
          <gml:name>L5 First Floor Usage Zone</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 4.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">80</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:type codeSpace="usageZone_type_codeSpace">office</nrg3:type>
          <nrg3:occupiedBy>
            <nrg3:Occupants gml:id="id_L5_occupants2">
              <gml:name>L5 First Floor Occupants</gml:name>
              <nrg3:type codeSpace="occupants_type_codeSpace">workers</nrg3:type>
              <nrg3:numberOfOccupants>5</nrg3:numberOfOccupants>
              <nrg3:heatDissipation uom="W">80</nrg3:heatDissipation>
              <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.50</nrg3:heatDissipationConvectiveFraction>
              <nrg3:heatDissipationLatentFraction uom="unit interval">0.50</nrg3:heatDissipationLatentFraction>
              <nrg3:heatDissipationRadiantFraction uom="unit interval">0.30</nrg3:heatDissipationRadiantFraction>
              <nrg3:occupancyRate xlink:href="#id_L5_occ_sched"/>
            </nrg3:Occupants>
          </nrg3:occupiedBy>
          <nrg3:internalHeatGains uom="W/m^2">20</nrg3:internalHeatGains>
          <nrg3:heatingSchedule xlink:href="#id_L5_heat_sched"/>
          <nrg3:coolingSchedule xlink:href="#id_L5_cool_sched"/>
          <nrg3:ventilationSchedule xlink:href="#id_L5_vent_sched"/>
        </nrg3:UsageZone>
      </nrg3:usageZone>

      <!-- ================================================================
           THERMAL ZONE 1 – Ground floor (z=[0,3])
           ================================================================ -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L5_tz1">
          <gml:description>Ground-floor office zone, 10×8×3m</gml:description>
          <gml:name>L5 Zone1 Ground Floor</gml:name>
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
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">240</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>
          <nrg3:heatCapacity uom="J/K">400000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.35</nrg3:infiltrationRate>
          <nrg3:isCooled>true</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- Ground slab (z=0) – outward normal: -Z, CCW from below -->
          <nrg3:thermalBoundary>
            <bldg:GroundSurface gml:id="id_L5_z1_ground">
              <gml:name>Ground (Z1)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z1_ground">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 10 8 0 10 0 0 0 0 0 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_ground"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:GroundSurface>
          </nrg3:thermalBoundary>

          <!-- South wall (y=0, z=[0,3]) – 1 window x=[2,8] z=[0.8,2.4] -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z1_wall_south">
              <gml:name>South Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <!-- South wall, outward normal -Y, CCW from south; interior ring = window hole -->
                    <gml:Polygon gml:id="id_L5_poly_z1_south">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 0 10 0 0 10 0 3 0 0 3 0 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                      <!-- Window hole: x=[2,8], z=[0.8,2.4] -->
                      <gml:interior>
                        <gml:LinearRing>
                          <gml:posList>2 0 0.8 2 0 2.4 8 0 2.4 8 0 0.8 2 0 0.8</gml:posList>
                        </gml:LinearRing>
                      </gml:interior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <!-- Window: 6 × 1.6 m = 9.6 m², south facing -->
              <bldg:opening>
                <bldg:Window gml:id="id_L5_z1_win1">
                  <gml:description>South window Z1: 6×1.6 m</gml:description>
                  <gml:name>L5 Z1 South Window</gml:name>
                  <bldg:lod3MultiSurface>
                    <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:surfaceMember>
                        <gml:Polygon gml:id="id_L5_poly_z1_win1">
                          <gml:exterior>
                            <gml:LinearRing>
                              <gml:posList>2 0 0.8 8 0 0.8 8 0 2.4 2 0 2.4 2 0 0.8</gml:posList>
                            </gml:LinearRing>
                          </gml:exterior>
                        </gml:Polygon>
                      </gml:surfaceMember>
                    </gml:MultiSurface>
                  </bldg:lod3MultiSurface>
                  <nrg3:layeredConstruction xlink:href="#id_L5_lc_glazing"/>
                  <nrg3:bdgOpnArea uom="m^2">9.6</nrg3:bdgOpnArea>
                  <nrg3:bdgOpnAzimuth uom="decimal degree">180</nrg3:bdgOpnAzimuth>
                  <nrg3:bdgOpnInclination uom="decimal degree">90</nrg3:bdgOpnInclination>
                  <nrg3:bdgOpnGroundViewFactor uom="unit interval">0.5</nrg3:bdgOpnGroundViewFactor>
                  <nrg3:bdgOpnSkyViewFactor uom="unit interval">0.5</nrg3:bdgOpnSkyViewFactor>
                </bldg:Window>
              </bldg:opening>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">180</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <!-- WWR = 9.6/30 = 0.32 -->
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.32</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfOpaqueSurfaceArea uom="m^2">20.4</nrg3:bdgBdrySurfOpaqueSurfaceArea>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- North wall (y=8, z=[0,3]) – exterior -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z1_wall_north">
              <gml:name>North Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z1_north">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 8 0 0 8 0 0 8 3 10 8 3 10 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall (x=10, z=[0,3]) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z1_wall_east">
              <gml:name>East Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z1_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 0 0 10 8 0 10 8 3 10 0 3 10 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall (x=0, z=[0,3]) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z1_wall_west">
              <gml:name>West Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z1_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 0 0 0 0 0 3 0 8 3 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">270</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- Intermediate ceiling (z=3) – adjacent to Zone2 floor via gen:stringAttribute -->
          <!-- Outward normal from Zone1 = +Z; CCW from above -->
          <nrg3:thermalBoundary>
            <bldg:CeilingSurface gml:id="id_L5_z1_ceiling">
              <gml:name>Intermediate Ceiling Z1 (adjacent to Z2 floor)</gml:name>
              <!-- Adjacency pre-annotation: parser resolves BC → 'surface' (Zone2 floor) -->
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L5_z2_floor</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z1_ceiling">
                      <gml:exterior>
                        <gml:LinearRing>
                          <!-- CCW from above (+Z normal) -->
                          <gml:posList>0 0 3 10 0 3 10 8 3 0 8 3 0 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_intfloor"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:CeilingSurface>
          </nrg3:thermalBoundary>

        </nrg3:ThermalZone>
      </nrg3:thermalZone>

      <!-- ================================================================
           THERMAL ZONE 2 – First floor (z=[3,6])
           ================================================================ -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L5_tz2">
          <gml:description>First-floor office zone, 10×8×3m</gml:description>
          <gml:name>L5 Zone2 First Floor</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 4.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">80</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">240</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>
          <nrg3:heatCapacity uom="J/K">400000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.30</nrg3:infiltrationRate>
          <nrg3:isCooled>true</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- Intermediate floor (z=3) – adjacent to Zone1 ceiling, reverse winding -->
          <!-- Outward normal from Zone2 = -Z; CCW from below = CW from above -->
          <nrg3:thermalBoundary>
            <bldg:CeilingSurface gml:id="id_L5_z2_floor">
              <gml:name>Intermediate Floor Z2 (adjacent to Z1 ceiling)</gml:name>
              <!-- Adjacency pre-annotation: parser resolves BC → 'surface' (Zone1 ceiling) -->
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L5_z1_ceiling</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z2_floor">
                      <gml:exterior>
                        <gml:LinearRing>
                          <!-- Reverse winding vs Z1 ceiling (-Z normal): CW from above = CCW from below -->
                          <gml:posList>0 8 3 10 8 3 10 0 3 0 0 3 0 8 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_intfloor"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:CeilingSurface>
          </nrg3:thermalBoundary>

          <!-- Roof (z=6) – outward normal +Z, CCW from above -->
          <nrg3:thermalBoundary>
            <bldg:RoofSurface gml:id="id_L5_z2_roof">
              <gml:name>Roof Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z2_roof">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 6 10 0 6 10 8 6 0 8 6 0 0 6</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_roof"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">1</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:RoofSurface>
          </nrg3:thermalBoundary>

          <!-- South wall (y=0, z=[3,6]) – 1 window x=[2,8] z=[3.8,5.4] -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z2_wall_south">
              <gml:name>South Wall Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z2_south">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 3 10 0 3 10 0 6 0 0 6 0 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                      <!-- Window hole: x=[2,8], z=[3.8,5.4] -->
                      <gml:interior>
                        <gml:LinearRing>
                          <gml:posList>2 0 3.8 2 0 5.4 8 0 5.4 8 0 3.8 2 0 3.8</gml:posList>
                        </gml:LinearRing>
                      </gml:interior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <!-- Window: 6 × 1.6 m = 9.6 m², south facing -->
              <bldg:opening>
                <bldg:Window gml:id="id_L5_z2_win1">
                  <gml:description>South window Z2: 6×1.6 m</gml:description>
                  <gml:name>L5 Z2 South Window</gml:name>
                  <bldg:lod3MultiSurface>
                    <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:surfaceMember>
                        <gml:Polygon gml:id="id_L5_poly_z2_win1">
                          <gml:exterior>
                            <gml:LinearRing>
                              <gml:posList>2 0 3.8 8 0 3.8 8 0 5.4 2 0 5.4 2 0 3.8</gml:posList>
                            </gml:LinearRing>
                          </gml:exterior>
                        </gml:Polygon>
                      </gml:surfaceMember>
                    </gml:MultiSurface>
                  </bldg:lod3MultiSurface>
                  <nrg3:layeredConstruction xlink:href="#id_L5_lc_glazing"/>
                  <nrg3:bdgOpnArea uom="m^2">9.6</nrg3:bdgOpnArea>
                  <nrg3:bdgOpnAzimuth uom="decimal degree">180</nrg3:bdgOpnAzimuth>
                  <nrg3:bdgOpnInclination uom="decimal degree">90</nrg3:bdgOpnInclination>
                  <nrg3:bdgOpnGroundViewFactor uom="unit interval">0.5</nrg3:bdgOpnGroundViewFactor>
                  <nrg3:bdgOpnSkyViewFactor uom="unit interval">0.5</nrg3:bdgOpnSkyViewFactor>
                </bldg:Window>
              </bldg:opening>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">180</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">0.5</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0.32</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfOpaqueSurfaceArea uom="m^2">20.4</nrg3:bdgBdrySurfOpaqueSurfaceArea>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- North wall (y=8, z=[3,6]) – party wall: adiabatic via flag -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z2_wall_north">
              <gml:name>North Party Wall Z2 (adiabatic)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z2_north">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 8 3 0 8 3 0 8 6 10 8 6 10 8 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <!-- adiabatic=true: shared party wall with adjacent building -->
              <nrg3:bdgBdrySurfIsAdiabatic>true</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall (x=10, z=[3,6]) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z2_wall_east">
              <gml:name>East Wall Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z2_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 0 3 10 8 3 10 8 6 10 0 6 10 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall (x=0, z=[3,6]) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L5_z2_wall_west">
              <gml:name>West Wall Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L5_poly_z2_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 3 0 0 3 0 0 6 0 8 6 0 8 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L5_lc_wall"/>
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
