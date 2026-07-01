<?xml version="1.0" encoding="UTF-8"?>
<!--
  L4_rich_windows.gml
  Parse path : RICH  (nrg3:thermalZone + nrg3:thermalBoundary)
  Geometry   : LoD3 thermalBoundary – 10 x 8 x 3 m OFFICE
  EnergyADE  : Explicit Window geometry, glazing construction (full optical properties),
               MovableShadingDevice (blind, inside), LightingDevice,
               UsageZone with Occupants + schedules (DualValue + AtomicSchedule + CompositeSchedule)
  Tests      : FenestrationSurface:Detailed geometry + simplify_to_quad()
               resolve_uvalue_construction() for glazing with transmittance/reflectance/emissivity
               MovableShadingDevice, LightingDevice, UsageZone (stored, not yet written to IDF)
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <gml:description>Synthetic test dataset – L4: rich path, explicit windows, devices, UsageZone</gml:description>
  <gml:name>L4 Rich Windows Office</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 3</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <!-- ================================================================
       Schedule Library (inline)
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:ScheduleLibrary gml:id="id_L4_schedule_library">
      <gml:description>Schedules for L4 office building</gml:description>
      <gml:name>L4 Schedule Library</gml:name>
      <nrg3:source>EN 16798-1 office profile</nrg3:source>

      <!-- Composite weekly schedule: 5 weekdays + 2 weekend days -->
      <nrg3:libraryMember>
        <nrg3:CompositeSchedule gml:id="id_L4_occ_weekly">
          <gml:description>Weekly occupancy composite: 5 weekdays + 2 weekend days</gml:description>
          <gml:name>L4 Weekly Occupancy Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">week</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">7</nrg3:temporalExtent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L4_sc_weekday">
              <gml:name>Weekday occupancy component</gml:name>
              <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
              <nrg3:repetitions>5</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L4_occ_weekday"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L4_sc_weekend">
              <gml:name>Weekend occupancy component</gml:name>
              <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
              <nrg3:repetitions>2</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L4_occ_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
        </nrg3:CompositeSchedule>
      </nrg3:libraryMember>

      <!-- Weekday occupancy: 24 hourly fractions (0=absent, 1=fully occupied) -->
      <!-- Profile: 0% nights, 100% 09:00-17:00, 50% 08:00-09:00 and 17:00-18:00 -->
      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L4_occ_weekday">
          <gml:description>Weekday office occupancy, hourly fractions</gml:description>
          <gml:name>L4 Weekday Occupancy</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L4_ts_occ_wd">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>discontinuous</nrg3:interpolationType>
              <nrg3:source>EN 16798-1 office category II</nrg3:source>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <!-- h00-h07: unoccupied; h08: 50%; h09-h17: 100%; h18: 50%; h19-h23: 0 -->
              <nrg3:valuesList uom="unit interval">
                0 0 0 0 0 0 0 0 0.5 1 1 1 1 1 1 1 1 1 0.5 0 0 0 0 0
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <!-- Weekend occupancy: zero (office unoccupied on weekends) -->
      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L4_occ_weekend">
          <gml:description>Weekend office occupancy – unoccupied</gml:description>
          <gml:name>L4 Weekend Occupancy</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L4_ts_occ_we">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>discontinuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <nrg3:valuesList uom="unit interval">
                0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <!-- Heating setpoint schedule: idle=18°C / usage=21°C (office hours) -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L4_heat_sched">
          <gml:description>Heating setpoint: 18°C setback / 21°C occupied</gml:description>
          <gml:name>L4 Heating Setpoint Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="degrees Celsius">18</nrg3:idleValue>
          <nrg3:usageValue uom="degrees Celsius">21</nrg3:usageValue>
          <nrg3:startUsageTime>08:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Cooling setpoint schedule: 26°C setback / 24°C occupied -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L4_cool_sched">
          <gml:description>Cooling setpoint: 26°C setback / 24°C occupied</gml:description>
          <gml:name>L4 Cooling Setpoint Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="degrees Celsius">26</nrg3:idleValue>
          <nrg3:usageValue uom="degrees Celsius">24</nrg3:usageValue>
          <nrg3:startUsageTime>08:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Ventilation schedule: off (idle=0) / on (usage=1) -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L4_vent_sched">
          <gml:description>Ventilation availability: off nights/weekends, on office hours</gml:description>
          <gml:name>L4 Ventilation Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="unit interval">0</nrg3:idleValue>
          <nrg3:usageValue uom="unit interval">1</nrg3:usageValue>
          <nrg3:startUsageTime>07:30:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:30:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Lighting control schedule: off when unoccupied, on when occupied -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L4_light_sched">
          <gml:description>Lighting control: 0 off / 1 on; matches occupancy hours</gml:description>
          <gml:name>L4 Lighting Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="unit interval">0</nrg3:idleValue>
          <nrg3:usageValue uom="unit interval">1</nrg3:usageValue>
          <nrg3:startUsageTime>08:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>18:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

      <!-- Shading schedule: 0=retracted (idle), 1=deployed (solar control hours) -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L4_shading_sched">
          <gml:description>Shading device: retracted at night, deployed during sunny hours</gml:description>
          <gml:name>L4 Shading Schedule</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:idleValue uom="unit interval">0</nrg3:idleValue>
          <nrg3:usageValue uom="unit interval">1</nrg3:usageValue>
          <nrg3:startUsageTime>10:00:00</nrg3:startUsageTime>
          <nrg3:endUsageTime>17:00:00</nrg3:endUsageTime>
        </nrg3:DualValueSchedule>
      </nrg3:libraryMember>

    </nrg3:ScheduleLibrary>
  </core:cityObjectMember>

  <!-- ================================================================
       Construction Library
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:LayeredConstructionLibrary gml:id="id_L4_lc_library">
      <gml:description>Constructions for L4 office building (2005)</gml:description>
      <gml:name>L4 Construction Library</gml:name>

      <!-- External wall: U=0.30 W/(m²·K) – well-insulated office -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L4_lc_wall">
          <gml:description>Modern office wall: plasterboard / concrete / XPS / render</gml:description>
          <gml:name>L4 Wall (layered)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.30</nrg3:uValue>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.90</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.30</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <!-- Layer 1: gypsum plasterboard (inside) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_wall_l1">
              <nrg3:thickness uom="mm">12.5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_plasterboard">
                  <gml:name>Gypsum Plasterboard</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.25</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.4</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">2.0e-10</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 2: hollow concrete block -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_wall_l2">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_hollow_concrete">
                  <gml:name>Hollow Concrete Block</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.79</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1400</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.35</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.5e-11</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 3: XPS thermal insulation board -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_wall_l3">
              <nrg3:thickness uom="mm">120</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_xps">
                  <gml:name>XPS Extruded Polystyrene</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.033</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">35</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.02</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">2.0e-13</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">26</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">3.0</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- Layer 4: thin-coat render (outside) -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_wall_l4">
              <nrg3:thickness uom="mm">10</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_thin_render">
                  <gml:name>Thin-coat Exterior Render</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1600</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.20</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.0e-10</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Roof: U=0.20 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L4_lc_roof">
          <gml:name>L4 Roof</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.20</nrg3:uValue>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_roof_l1">
              <nrg3:thickness uom="mm">15</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_gyp_roof">
                  <gml:name>Gypsum Plaster (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_roof_l2">
              <nrg3:thickness uom="mm">250</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_rc_roof">
                  <gml:name>Reinforced Concrete (roof)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_roof_l3">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_pir">
                  <gml:name>PIR Polyisocyanurate Insulation</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.022</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">32</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.02</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.0e-14</nrg3:permeance>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_roof_l4">
              <nrg3:thickness uom="mm">5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_mem">
                  <gml:name>EPDM Waterproofing Membrane</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.25</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1100</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Ground slab: U=0.30 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L4_lc_ground">
          <gml:name>L4 Ground Slab</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.30</nrg3:uValue>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_ground_l1">
              <nrg3:thickness uom="mm">60</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_screed">
                  <gml:name>Cement Screed</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_ground_l2">
              <nrg3:thickness uom="mm">120</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_xps_floor">
                  <gml:name>XPS Floor Insulation</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.033</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">35</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L4_lc_ground_l3">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L4_mat_slab">
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

      <!-- Triple glazing: U=1.2 W/(m²·K), g=0.5, full optical properties -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L4_lc_glazing">
          <gml:description>Triple glazing: U=1.2, g=0.5, low-e coating inside</gml:description>
          <gml:name>L4 Triple Glazing</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">1.2</nrg3:uValue>
          <nrg3:glazingRatio uom="unit interval">0.90</nrg3:glazingRatio>
          <!-- Solar energy transmittance (g-value) encoded as solar transmittance -->
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.45</nrg3:fraction>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <!-- Visible light transmittance -->
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.72</nrg3:fraction>
              <nrg3:wavelengthRange>visible</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <!-- Solar reflectance outside face -->
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.25</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <!-- IR reflectance inside face (low-e) -->
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.88</nrg3:fraction>
              <nrg3:surface>inside</nrg3:surface>
              <nrg3:wavelengthRange>infrared</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <!-- Emissivity inside face (low-e coating: ε ≈ 0.10) -->
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.10</nrg3:fraction>
              <nrg3:surface>inside</nrg3:surface>
            </nrg3:Emissivity>
          </nrg3:emissivity>
          <!-- Emissivity outside face (clear glass: ε ≈ 0.84) -->
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
    <bldg:Building gml:id="id_L4_building">
      <gml:description>L4 – office building, LoD3 rich path, windows + devices + UsageZone</gml:description>
      <gml:name>L4 Office Rich</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 1.5</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <bldg:function>office</bldg:function>
      <bldg:yearOfConstruction>2005</bldg:yearOfConstruction>
      <bldg:measuredHeight uom="m">3</bldg:measuredHeight>
      <bldg:storeysAboveGround>1</bldg:storeysAboveGround>
      <bldg:storeyHeightsAboveGround uom="m">3</bldg:storeyHeightsAboveGround>

      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">medium</nrg3:bdgConstructionWeight>

      <!-- Building-level area/height -->
      <nrg3:area>
        <nrg3:QualifiedArea>
          <nrg3:value uom="m^2">80</nrg3:value>
          <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
        </nrg3:QualifiedArea>
      </nrg3:area>
      <nrg3:height>
        <nrg3:QualifiedHeight>
          <nrg3:value uom="m">3</nrg3:value>
          <nrg3:type codeSpace="height_codeSpace">measuredHeight</nrg3:type>
        </nrg3:QualifiedHeight>
      </nrg3:height>

      <!-- ───────────────────────── DEVICES ── -->

      <!-- Lighting device: LED, 10 W/m² installed power -->
      <nrg3:device>
        <nrg3:LightingDevice gml:id="id_L4_lighting">
          <gml:description>LED office luminaires, zone average</gml:description>
          <gml:name>L4 LED Lighting</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 2.7</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:model>LED Panel 60x60</nrg3:model>
          <nrg3:yearOfManufacture>2023</nrg3:yearOfManufacture>
          <nrg3:numberOfDevices>10</nrg3:numberOfDevices>
          <!-- 10 W/m² × 80 m² = 800 W installed -->
          <nrg3:installedPower uom="W">800</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.92</nrg3:nominalEfficiency>
          <nrg3:efficiencyIndicator>luminous efficacy 130 lm/W</nrg3:efficiencyIndicator>
          <!-- Heat dissipation fractions (EnergyPlus Lights object) -->
          <nrg3:heatDissipation uom="W/m^2">10</nrg3:heatDissipation>
          <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.59</nrg3:heatDissipationConvectiveFraction>
          <nrg3:heatDissipationLatentFraction uom="unit interval">0.00</nrg3:heatDissipationLatentFraction>
          <nrg3:heatDissipationRadiantFraction uom="unit interval">0.32</nrg3:heatDissipationRadiantFraction>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L4_lighting_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">lighting</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L4_light_sched"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:LightingDevice>
      </nrg3:device>

      <!-- Movable shading device on south windows: internal blinds -->
      <nrg3:device>
        <nrg3:MovableShadingDevice gml:id="id_L4_shading">
          <gml:description>Internal textile blinds on south-facing windows</gml:description>
          <gml:name>L4 Internal Blind</gml:name>
          <nrg3:model>Blind 100mm slat</nrg3:model>
          <nrg3:type codeSpace="shading_type_codeSpace">blind</nrg3:type>
          <nrg3:installationSide>inside</nrg3:installationSide>
          <nrg3:maximumCoverRatio uom="unit interval">0.95</nrg3:maximumCoverRatio>
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.04</nrg3:fraction>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L4_shading_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">shading</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L4_shading_sched"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:MovableShadingDevice>
      </nrg3:device>

      <!-- Generic electrical appliances (computers, monitors, etc.) -->
      <nrg3:device>
        <nrg3:GenericElectricalDevice gml:id="id_L4_equip">
          <gml:description>Office IT equipment (computers, monitors, servers)</gml:description>
          <gml:name>L4 Office Equipment</gml:name>
          <nrg3:numberOfDevices>10</nrg3:numberOfDevices>
          <!-- 15 W/m² × 80 m² = 1200 W -->
          <nrg3:installedPower uom="W">1200</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.85</nrg3:nominalEfficiency>
          <nrg3:heatDissipation uom="W/m^2">15</nrg3:heatDissipation>
          <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.60</nrg3:heatDissipationConvectiveFraction>
          <nrg3:heatDissipationLatentFraction uom="unit interval">0.00</nrg3:heatDissipationLatentFraction>
          <nrg3:heatDissipationRadiantFraction uom="unit interval">0.40</nrg3:heatDissipationRadiantFraction>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L4_equip_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">electricalAppliances</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L4_occ_weekday"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:GenericElectricalDevice>
      </nrg3:device>

      <!-- ───────────────────────── USAGE ZONE ── -->

      <nrg3:usageZone>
        <nrg3:UsageZone gml:id="id_L4_uz1">
          <gml:description>Office usage zone: workers, 08:00-18:00 weekdays</gml:description>
          <gml:name>L4 Office Usage Zone</gml:name>
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

          <!-- Occupants -->
          <nrg3:occupiedBy>
            <nrg3:Occupants gml:id="id_L4_occupants">
              <gml:description>Office workers</gml:description>
              <gml:name>L4 Occupants</gml:name>
              <nrg3:type codeSpace="occupants_type_codeSpace">workers</nrg3:type>
              <!-- 10 persons total (0.125 person/m²) -->
              <nrg3:numberOfOccupants>10</nrg3:numberOfOccupants>
              <!-- Heat dissipation per person (ISO 7730 seated light office work) -->
              <nrg3:heatDissipation uom="W">80</nrg3:heatDissipation>
              <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.50</nrg3:heatDissipationConvectiveFraction>
              <nrg3:heatDissipationLatentFraction uom="unit interval">0.50</nrg3:heatDissipationLatentFraction>
              <nrg3:heatDissipationRadiantFraction uom="unit interval">0.30</nrg3:heatDissipationRadiantFraction>
              <!-- Occupancy rate schedule (fraction 0-1, links to composite weekly schedule) -->
              <nrg3:occupancyRate xlink:href="#id_L4_occ_weekly"/>
            </nrg3:Occupants>
          </nrg3:occupiedBy>

          <!-- Internal heat gains (total, W/m²) -->
          <nrg3:internalHeatGains uom="W/m^2">25</nrg3:internalHeatGains>
          <nrg3:internalHeatGainsConvectiveFraction uom="unit interval">0.55</nrg3:internalHeatGainsConvectiveFraction>
          <nrg3:internalHeatGainsLatentFraction uom="unit interval">0.10</nrg3:internalHeatGainsLatentFraction>
          <nrg3:internalHeatGainsRadiantFraction uom="unit interval">0.35</nrg3:internalHeatGainsRadiantFraction>

          <!-- HVAC setpoint schedules -->
          <nrg3:heatingSchedule xlink:href="#id_L4_heat_sched"/>
          <nrg3:coolingSchedule xlink:href="#id_L4_cool_sched"/>
          <nrg3:ventilationSchedule xlink:href="#id_L4_vent_sched"/>

        </nrg3:UsageZone>
      </nrg3:usageZone>

      <!-- ───────────────────────── THERMAL ZONE ── -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L4_tz1">
          <gml:description>Single office thermal zone with LoD3 boundaries and windows</gml:description>
          <gml:name>L4 Office ThermalZone</gml:name>
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
              <nrg3:type codeSpace="area_codeSpace">energyReferenceArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">240</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>

          <nrg3:heatCapacity uom="J/K">400000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.3</nrg3:infiltrationRate>
          <nrg3:isCooled>true</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- Ground -->
          <nrg3:thermalBoundary>
            <bldg:GroundSurface gml:id="id_L4_tz1_ground">
              <gml:name>Ground (L4)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L4_poly_ground">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 10 8 0 10 0 0 0 0 0 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L4_lc_ground"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:GroundSurface>
          </nrg3:thermalBoundary>

          <!-- Roof -->
          <nrg3:thermalBoundary>
            <bldg:RoofSurface gml:id="id_L4_tz1_roof">
              <gml:name>Roof (L4)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L4_poly_roof">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 3 10 0 3 10 8 3 0 8 3 0 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L4_lc_roof"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">1</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:RoofSurface>
          </nrg3:thermalBoundary>

          <!-- South wall (y=0) – contains 2 windows -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L4_tz1_wall_south">
              <gml:name>South Wall (L4) – main facade with windows</gml:name>
              <nrg3:referencePoint>
                <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:pos>5 0 1.5</gml:pos>
                </gml:Point>
              </nrg3:referencePoint>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <!-- South wall polygon with interior rings for window openings -->
                    <gml:Polygon gml:id="id_L4_poly_south">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 0 10 0 0 10 0 3 0 0 3 0 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                      <!-- Window 1 hole: x=[1,4], z=[0.8,2.4] -->
                      <gml:interior>
                        <gml:LinearRing>
                          <gml:posList>1 0 0.8 1 0 2.4 4 0 2.4 4 0 0.8 1 0 0.8</gml:posList>
                        </gml:LinearRing>
                      </gml:interior>
                      <!-- Window 2 hole: x=[6,9], z=[0.8,2.4] -->
                      <gml:interior>
                        <gml:LinearRing>
                          <gml:posList>6 0 0.8 6 0 2.4 9 0 2.4 9 0 0.8 6 0 0.8</gml:posList>
                        </gml:LinearRing>
                      </gml:interior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L4_lc_wall"/>

              <!-- Window 1: western bay -->
              <bldg:opening>
                <bldg:Window gml:id="id_L4_win1">
                  <gml:description>South window 1 (west bay): 3x1.6 m</gml:description>
                  <gml:name>L4 South Window W</gml:name>
                  <nrg3:referencePoint>
                    <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:pos>2.5 0 1.6</gml:pos>
                    </gml:Point>
                  </nrg3:referencePoint>
                  <bldg:lod3MultiSurface>
                    <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:surfaceMember>
                        <!-- Quad: x=[1,4], z=[0.8,2.4], y=0 – CCW from south -->
                        <gml:Polygon gml:id="id_L4_poly_win1">
                          <gml:exterior>
                            <gml:LinearRing>
                              <gml:posList>1 0 0.8 4 0 0.8 4 0 2.4 1 0 2.4 1 0 0.8</gml:posList>
                            </gml:LinearRing>
                          </gml:exterior>
                        </gml:Polygon>
                      </gml:surfaceMember>
                    </gml:MultiSurface>
                  </bldg:lod3MultiSurface>
                  <nrg3:layeredConstruction xlink:href="#id_L4_lc_glazing"/>
                  <nrg3:bdgOpnArea uom="m^2">4.8</nrg3:bdgOpnArea>
                  <nrg3:bdgOpnAzimuth uom="decimal degree">180</nrg3:bdgOpnAzimuth>
                  <nrg3:bdgOpnInclination uom="decimal degree">90</nrg3:bdgOpnInclination>
                  <nrg3:bdgOpnGroundViewFactor uom="unit interval">0.5</nrg3:bdgOpnGroundViewFactor>
                  <nrg3:bdgOpnSkyViewFactor uom="unit interval">0.5</nrg3:bdgOpnSkyViewFactor>
                </bldg:Window>
              </bldg:opening>

              <!-- Window 2: eastern bay -->
              <bldg:opening>
                <bldg:Window gml:id="id_L4_win2">
                  <gml:description>South window 2 (east bay): 3x1.6 m</gml:description>
                  <gml:name>L4 South Window E</gml:name>
                  <nrg3:referencePoint>
                    <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:pos>7.5 0 1.6</gml:pos>
                    </gml:Point>
                  </nrg3:referencePoint>
                  <bldg:lod3MultiSurface>
                    <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:surfaceMember>
                        <!-- Quad: x=[6,9], z=[0.8,2.4], y=0 – CCW from south -->
                        <gml:Polygon gml:id="id_L4_poly_win2">
                          <gml:exterior>
                            <gml:LinearRing>
                              <gml:posList>6 0 0.8 9 0 0.8 9 0 2.4 6 0 2.4 6 0 0.8</gml:posList>
                            </gml:LinearRing>
                          </gml:exterior>
                        </gml:Polygon>
                      </gml:surfaceMember>
                    </gml:MultiSurface>
                  </bldg:lod3MultiSurface>
                  <nrg3:layeredConstruction xlink:href="#id_L4_lc_glazing"/>
                  <nrg3:bdgOpnArea uom="m^2">4.8</nrg3:bdgOpnArea>
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

          <!-- North wall (y=8) – opaque -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L4_tz1_wall_north">
              <gml:name>North Wall (L4)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L4_poly_north">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 8 0 0 8 0 0 8 3 10 8 3 10 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L4_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall (x=10) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L4_tz1_wall_east">
              <gml:name>East Wall (L4)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L4_poly_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 0 0 10 8 0 10 8 3 10 0 3 10 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L4_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall (x=0) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L4_tz1_wall_west">
              <gml:name>West Wall (L4)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L4_poly_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 0 0 0 0 0 3 0 8 3 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L4_lc_wall"/>
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
