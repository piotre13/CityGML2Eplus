<?xml version="1.0" encoding="UTF-8"?>
<!--
  L6_full_rich.gml
  Parse path : RICH  (nrg3:thermalZone + nrg3:thermalBoundary)
  Geometry   : LoD3 – 10 × 8 × 6 m three-zone OFFICE (year 2010)
  EnergyADE  : 3 ThermalZones (Z1 south-GF, Z2 north-GF, Z3 FF)
               Internal wall adjacency (Z1↔Z2), ceiling/floor adjacency (Z1/Z2↔Z3)
               PartyWallSurface (Z2 north), ReverseLayeredConstruction
               9 device types: Boiler, HeatPump, LightingDevice×3, MovableShadingDevice,
                 SolarThermalCollector, PhotovoltaicCollector, ThermalStorageDevice,
                 ElectricalStorageDevice, GenericDevice (HRV)
               CompositeSchedule+AtomicSchedule+TypicalValuesTimeSeries
               WeatherStation, EPC, RefurbishmentMeasure, 3×UtilityNetworkConnection
               EnergyCarrier×3, embodiedEnergy+embodiedCarbon on all materials
  Tests      : Full EnergyADE feature coverage for converter validation
-->
<core:CityModel
  xmlns:core="http://www.opengis.net/citygml/2.0"
  xmlns:bldg="http://www.opengis.net/citygml/building/2.0"
  xmlns:nrg3="http://www.citygml.org/ade/energy/3.0"
  xmlns:gen="http://www.opengis.net/citygml/generics/2.0"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <gml:description>Synthetic test dataset – L6: rich path, 3 zones, all EnergyADE features</gml:description>
  <gml:name>L6 Full Rich Office</gml:name>
  <gml:boundedBy>
    <gml:Envelope srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
      <gml:lowerCorner>0 0 0</gml:lowerCorner>
      <gml:upperCorner>10 8 6</gml:upperCorner>
    </gml:Envelope>
  </gml:boundedBy>

  <!-- ================================================================
       Schedule Library – CompositeSchedule + AtomicSchedule pattern
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:ScheduleLibrary gml:id="id_L6_schedule_library">
      <gml:description>Schedules for L6 office: composite weekly profiles with hourly atomics</gml:description>
      <gml:name>L6 Schedule Library</gml:name>
      <nrg3:source>EN 16798-1 office category II</nrg3:source>

      <!-- ── OCCUPANCY ── -->
      <nrg3:libraryMember>
        <nrg3:CompositeSchedule gml:id="id_L6_occ_weekly">
          <gml:name>L6 Weekly Occupancy</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">week</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">7</nrg3:temporalExtent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_occ_wd">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
              <nrg3:repetitions>5</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_occ_weekday"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_occ_we">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_occ_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_occ_hol">
              <nrg3:type codeSpace="schedule_type_codeSpace">holiday</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_occ_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
        </nrg3:CompositeSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_occ_weekday">
          <gml:name>L6 Occupancy Weekday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_occ_wd">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>discontinuous</nrg3:interpolationType>
              <nrg3:source>EN 16798-1</nrg3:source>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <!-- h00-h07: 0; h08: 0.5; h09-h17: 1; h18: 0.5; h19-h23: 0 -->
              <nrg3:valuesList uom="unit interval">
                0 0 0 0 0 0 0 0 0.5 1 1 1 1 1 1 1 1 1 0.5 0 0 0 0 0
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_occ_weekend">
          <gml:name>L6 Occupancy Weekend/Holiday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_occ_we">
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

      <!-- ── HEATING SETPOINT ── -->
      <nrg3:libraryMember>
        <nrg3:CompositeSchedule gml:id="id_L6_heat_weekly">
          <gml:name>L6 Weekly Heating Setpoint</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">week</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">7</nrg3:temporalExtent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_heat_wd">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
              <nrg3:repetitions>5</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_heat_weekday"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_heat_we">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_heat_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_heat_hol">
              <nrg3:type codeSpace="schedule_type_codeSpace">holiday</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_heat_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
        </nrg3:CompositeSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_heat_weekday">
          <gml:name>L6 Heating Setpoint Weekday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_heat_wd">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>continuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <!-- setback 18°C nights; ramp at h08→19; occupied 21°C h09-h17; setback h18→ -->
              <nrg3:valuesList uom="degrees Celsius">
                18 18 18 18 18 18 18 18 19 21 21 21 21 21 21 21 21 21 19 18 18 18 18 18
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_heat_weekend">
          <gml:name>L6 Heating Setpoint Weekend/Holiday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_heat_we">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>continuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <nrg3:valuesList uom="degrees Celsius">
                18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <!-- ── COOLING SETPOINT ── -->
      <nrg3:libraryMember>
        <nrg3:CompositeSchedule gml:id="id_L6_cool_weekly">
          <gml:name>L6 Weekly Cooling Setpoint</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">week</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">7</nrg3:temporalExtent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_cool_wd">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
              <nrg3:repetitions>5</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_cool_weekday"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_cool_we">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_cool_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_cool_hol">
              <nrg3:type codeSpace="schedule_type_codeSpace">holiday</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_cool_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
        </nrg3:CompositeSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_cool_weekday">
          <gml:name>L6 Cooling Setpoint Weekday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_cool_wd">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>continuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <!-- setback 26°C nights; 24°C occupied h09-h17 -->
              <nrg3:valuesList uom="degrees Celsius">
                26 26 26 26 26 26 26 26 25 24 24 24 24 24 24 24 24 24 25 26 26 26 26 26
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_cool_weekend">
          <gml:name>L6 Cooling Setpoint Weekend/Holiday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_cool_we">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>continuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <nrg3:valuesList uom="degrees Celsius">
                26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <!-- ── VENTILATION ── -->
      <nrg3:libraryMember>
        <nrg3:CompositeSchedule gml:id="id_L6_vent_weekly">
          <gml:name>L6 Weekly Ventilation</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">week</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">7</nrg3:temporalExtent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_vent_wd">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
              <nrg3:repetitions>5</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_vent_weekday"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_vent_we">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_vent_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_vent_hol">
              <nrg3:type codeSpace="schedule_type_codeSpace">holiday</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_vent_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
        </nrg3:CompositeSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_vent_weekday">
          <gml:name>L6 Ventilation Weekday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_vent_wd">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>discontinuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <!-- off h00-h06; ramp h07; on h08-h18; ramp h19; off h20-h23 -->
              <nrg3:valuesList uom="unit interval">
                0 0 0 0 0 0 0 0.5 1 1 1 1 1 1 1 1 1 1 1 0.5 0 0 0 0
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_vent_weekend">
          <gml:name>L6 Ventilation Weekend/Holiday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_vent_we">
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

      <!-- ── LIGHTING ── -->
      <nrg3:libraryMember>
        <nrg3:CompositeSchedule gml:id="id_L6_light_weekly">
          <gml:name>L6 Weekly Lighting</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">week</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">7</nrg3:temporalExtent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_light_wd">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
              <nrg3:repetitions>5</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_light_weekday"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_light_we">
              <nrg3:type codeSpace="schedule_type_codeSpace">weekendDay</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_occ_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
          <nrg3:scheduleComponent>
            <nrg3:ScheduleComponent gml:id="id_L6_sc_light_hol">
              <nrg3:type codeSpace="schedule_type_codeSpace">holiday</nrg3:type>
              <nrg3:repetitions>1</nrg3:repetitions>
              <nrg3:additionalGap unit="day">0</nrg3:additionalGap>
              <nrg3:scheduleComponentMember xlink:href="#id_L6_occ_weekend"/>
            </nrg3:ScheduleComponent>
          </nrg3:scheduleComponent>
        </nrg3:CompositeSchedule>
      </nrg3:libraryMember>

      <nrg3:libraryMember>
        <nrg3:AtomicSchedule gml:id="id_L6_light_weekday">
          <gml:name>L6 Lighting Weekday</gml:name>
          <nrg3:type codeSpace="schedule_type_codeSpace">weekDay</nrg3:type>
          <nrg3:startTime>00:00:00</nrg3:startTime>
          <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
          <nrg3:timeSeries>
            <nrg3:TypicalValuesTimeSeries gml:id="id_L6_ts_light_wd">
              <nrg3:acquisitionMethod codeSpace="acq_method_codeSpace">estimation</nrg3:acquisitionMethod>
              <nrg3:interpolationType>discontinuous</nrg3:interpolationType>
              <nrg3:temporalExtent unit="day">1</nrg3:temporalExtent>
              <nrg3:timeInterval unit="hour">1</nrg3:timeInterval>
              <nrg3:valuesList uom="unit interval">
                0 0 0 0 0 0 0 0 0.5 1 1 1 1 1 1 1 1 1 0.5 0 0 0 0 0
              </nrg3:valuesList>
            </nrg3:TypicalValuesTimeSeries>
          </nrg3:timeSeries>
        </nrg3:AtomicSchedule>
      </nrg3:libraryMember>

      <!-- ── SHADING ── -->
      <nrg3:libraryMember>
        <nrg3:DualValueSchedule gml:id="id_L6_shading_sched">
          <gml:description>Shading: retracted (0) / deployed (1) during solar hours</gml:description>
          <gml:name>L6 Shading Schedule</gml:name>
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
       Construction Library – full optical + embodied energy/carbon
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:LayeredConstructionLibrary gml:id="id_L6_lc_library">
      <gml:description>Constructions for L6 office (year 2010) – all materials with embodied energy/carbon</gml:description>
      <gml:name>L6 Construction Library</gml:name>

      <!-- External wall: U=0.30 W/(m²·K) – high-performance 2010 office -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L6_lc_wall">
          <gml:description>External wall: RC + XPS + render</gml:description>
          <gml:name>L6 External Wall</gml:name>
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
          <!-- L1: plasterboard inside -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_wall_l1">
              <nrg3:thickness uom="mm">12.5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_plasterboard">
                  <gml:name>Gypsum Plasterboard</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.25</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.40</nrg3:porosity>
                  <nrg3:embodiedEnergy uom="kWh/kg">3.5</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.38</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- L2: RC structural wall -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_wall_l2">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_rc_wall">
                  <gml:name>Reinforced Concrete (wall)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.95</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.13</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- L3: XPS insulation -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_wall_l3">
              <nrg3:thickness uom="mm">140</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_xps_wall">
                  <gml:name>XPS Extruded Polystyrene (wall)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.033</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">35</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.02</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">2.0e-13</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">26.0</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">3.0</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- L4: exterior render coat -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_wall_l4">
              <nrg3:thickness uom="mm">10</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_render">
                  <gml:name>Thin-coat Exterior Render</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1600</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">1.1</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.17</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Roof: U=0.20 W/(m²·K) – RC + PIR 200mm (refurbished 2015) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L6_lc_roof">
          <gml:description>Flat roof: gypsum + RC + PIR + EPDM membrane</gml:description>
          <gml:name>L6 Flat Roof (post-refurb)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.20</nrg3:uValue>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_roof_l1">
              <nrg3:thickness uom="mm">15</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_gyp_roof">
                  <gml:name>Gypsum Plaster (ceiling)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">1.8</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.18</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_roof_l2">
              <nrg3:thickness uom="mm">250</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_rc_roof">
                  <gml:name>Reinforced Concrete (roof slab)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.95</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.13</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_roof_l3">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_pir">
                  <gml:name>PIR Polyisocyanurate (roof upgrade 2015)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.022</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">32</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:porosity uom="unit interval">0.02</nrg3:porosity>
                  <nrg3:permeance uom="kg/(m^2*s*Pa)">1.0e-14</nrg3:permeance>
                  <nrg3:embodiedEnergy uom="kWh/kg">27.0</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">3.5</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_roof_l4">
              <nrg3:thickness uom="mm">5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_epdm">
                  <gml:name>EPDM Waterproofing Membrane</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.25</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">1100</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">30.0</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">3.2</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Ground slab: U=0.30 W/(m²·K) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L6_lc_ground">
          <gml:name>L6 Ground Slab</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.30</nrg3:uValue>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_ground_l1">
              <nrg3:thickness uom="mm">60</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_screed">
                  <gml:name>Cement Screed</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.40</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2000</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.7</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.11</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_ground_l2">
              <nrg3:thickness uom="mm">120</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_xps_floor">
                  <gml:name>XPS Floor Insulation</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.033</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">35</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1450</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">26.0</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">3.0</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_ground_l3">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_rc_slab">
                  <gml:name>RC Ground Slab</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.95</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.13</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Intermediate floor: RC slab only (no insulation) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L6_lc_intfloor">
          <gml:name>L6 Intermediate Floor Slab</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">3.5</nrg3:uValue>
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_intfloor_l1">
              <nrg3:thickness uom="mm">200</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_rc_intfloor">
                  <gml:name>RC Intermediate Floor Slab</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">1.70</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">2300</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">0.95</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.13</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Interior partition wall (Z1 N-wall face) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L6_lc_intwall">
          <gml:description>Lightweight interior partition: plasterboard + MW stud + plasterboard</gml:description>
          <gml:name>L6 Interior Partition Wall</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.32</nrg3:uValue>
          <!-- L1: Zone1-side plasterboard -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_intwall_l1">
              <nrg3:thickness uom="mm">12.5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_pb_int1">
                  <gml:name>Plasterboard (inside face)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.25</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">3.5</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.38</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- L2: mineral wool in stud cavity -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_intwall_l2">
              <nrg3:thickness uom="mm">100</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_mw_stud">
                  <gml:name>Mineral Wool in Stud Cavity</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.036</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">45</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">840</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">16.6</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">1.28</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
          <!-- L3: Zone2-side plasterboard -->
          <nrg3:layer>
            <nrg3:Layer gml:id="id_L6_lc_intwall_l3">
              <nrg3:thickness uom="mm">12.5</nrg3:thickness>
              <nrg3:material>
                <nrg3:SolidMaterial gml:id="id_L6_mat_pb_int2">
                  <gml:name>Plasterboard (outside face)</gml:name>
                  <nrg3:thermalConductivity uom="W/(K*m)">0.25</nrg3:thermalConductivity>
                  <nrg3:density uom="kg/m^3">800</nrg3:density>
                  <nrg3:specificHeatCapacity uom="J/(kg*K)">1000</nrg3:specificHeatCapacity>
                  <nrg3:embodiedEnergy uom="kWh/kg">3.5</nrg3:embodiedEnergy>
                  <nrg3:embodiedCarbon uom="kg/kg">0.38</nrg3:embodiedCarbon>
                </nrg3:SolidMaterial>
              </nrg3:material>
            </nrg3:Layer>
          </nrg3:layer>
        </nrg3:LayeredConstruction>
      </nrg3:libraryMember>

      <!-- Interior partition wall – reversed (used by Z2 south internal face) -->
      <nrg3:libraryMember>
        <nrg3:ReverseLayeredConstruction gml:id="id_L6_lc_intwall_rev">
          <gml:description>Reversed interior partition – same physical wall, seen from Zone2 side</gml:description>
          <gml:name>L6 Interior Partition Wall (reversed)</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">0.32</nrg3:uValue>
          <nrg3:reverseOf xlink:href="#id_L6_lc_intwall"/>
        </nrg3:ReverseLayeredConstruction>
      </nrg3:libraryMember>

      <!-- Triple glazing: U=1.2, full optical properties (same as L4) -->
      <nrg3:libraryMember>
        <nrg3:LayeredConstruction gml:id="id_L6_lc_glazing">
          <gml:description>Triple glazing: U=1.2, solar τ=0.45, low-e coating inside</gml:description>
          <gml:name>L6 Triple Glazing</gml:name>
          <nrg3:uValue uom="W/(K*m^2)">1.2</nrg3:uValue>
          <nrg3:glazingRatio uom="unit interval">0.90</nrg3:glazingRatio>
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.45</nrg3:fraction>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <nrg3:transmittance>
            <nrg3:Transmittance>
              <nrg3:fraction uom="unit interval">0.72</nrg3:fraction>
              <nrg3:wavelengthRange>visible</nrg3:wavelengthRange>
            </nrg3:Transmittance>
          </nrg3:transmittance>
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.25</nrg3:fraction>
              <nrg3:surface>outside</nrg3:surface>
              <nrg3:wavelengthRange>solar</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <nrg3:reflectance>
            <nrg3:Reflectance>
              <nrg3:fraction uom="unit interval">0.88</nrg3:fraction>
              <nrg3:surface>inside</nrg3:surface>
              <nrg3:wavelengthRange>infrared</nrg3:wavelengthRange>
            </nrg3:Reflectance>
          </nrg3:reflectance>
          <nrg3:emissivity>
            <nrg3:Emissivity>
              <nrg3:fraction uom="unit interval">0.10</nrg3:fraction>
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

  <!-- ================================================================
       Energy Carriers (cityObjectMember per carrier)
       ================================================================ -->
  <core:cityObjectMember>
    <nrg3:EnergyCarrier gml:id="id_L6_ec_elec">
      <gml:name>Electrical Energy</gml:name>
      <nrg3:type codeSpace="energy_carrier_type_codeSpace">electricalEnergy</nrg3:type>
      <nrg3:primaryEnergyFactor uom="unit interval">2.5</nrg3:primaryEnergyFactor>
      <nrg3:CO2EmissionFactor uom="kg/kWh">0.233</nrg3:CO2EmissionFactor>
    </nrg3:EnergyCarrier>
  </core:cityObjectMember>

  <core:cityObjectMember>
    <nrg3:EnergyCarrier gml:id="id_L6_ec_gas">
      <gml:name>Natural Gas</gml:name>
      <nrg3:type codeSpace="energy_carrier_type_codeSpace">naturalGas</nrg3:type>
      <nrg3:primaryEnergyFactor uom="unit interval">1.1</nrg3:primaryEnergyFactor>
      <nrg3:CO2EmissionFactor uom="kg/kWh">0.202</nrg3:CO2EmissionFactor>
    </nrg3:EnergyCarrier>
  </core:cityObjectMember>

  <core:cityObjectMember>
    <nrg3:EnergyCarrier gml:id="id_L6_ec_dhw">
      <gml:name>Domestic Hot Water (gas-fired)</gml:name>
      <nrg3:type codeSpace="energy_carrier_type_codeSpace">domesticHotWater</nrg3:type>
      <nrg3:primaryEnergyFactor uom="unit interval">1.1</nrg3:primaryEnergyFactor>
      <nrg3:CO2EmissionFactor uom="kg/kWh">0.202</nrg3:CO2EmissionFactor>
    </nrg3:EnergyCarrier>
  </core:cityObjectMember>

  <!-- ================================================================
       Building
       ================================================================ -->
  <core:cityObjectMember>
    <bldg:Building gml:id="id_L6_building">
      <gml:description>L6 – three-zone office, year 2010, all EnergyADE features</gml:description>
      <gml:name>L6 Full Rich Office</gml:name>
      <core:creationDate>2026-01-01</core:creationDate>

      <nrg3:referencePoint>
        <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
          <gml:pos>5 4 3</gml:pos>
        </gml:Point>
      </nrg3:referencePoint>

      <bldg:function>office</bldg:function>
      <bldg:yearOfConstruction>2010</bldg:yearOfConstruction>
      <bldg:measuredHeight uom="m">6</bldg:measuredHeight>
      <bldg:storeysAboveGround>2</bldg:storeysAboveGround>
      <bldg:storeyHeightsAboveGround uom="m">3</bldg:storeyHeightsAboveGround>

      <nrg3:bdgConstructionWeight codeSpace="construction_weight_codeSpace">heavy</nrg3:bdgConstructionWeight>

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

      <!-- ───────────────────────── WEATHER STATION ── -->

      <nrg3:weatherStation>
        <nrg3:WeatherStation gml:id="id_L6_ws">
          <gml:name>L6 On-site Weather Station</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 6</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:weatherData>
            <nrg3:WeatherData gml:id="id_L6_wd_temp">
              <nrg3:type codeSpace="weather_data_type_codeSpace">airTemperature</nrg3:type>
              <nrg3:timeSeries>
                <nrg3:RegularTimeSeries gml:id="id_L6_ts_temp">
                  <nrg3:timeInterval unit="month">1</nrg3:timeInterval>
                  <nrg3:temporalExtent unit="year">1</nrg3:temporalExtent>
                  <!-- Monthly mean air temperature (°C): Jan–Dec -->
                  <nrg3:valuesList uom="degrees Celsius">2.1 3.4 7.2 11.5 16.1 19.4 21.8 21.3 17.6 12.3 7.0 3.2</nrg3:valuesList>
                </nrg3:RegularTimeSeries>
              </nrg3:timeSeries>
            </nrg3:WeatherData>
          </nrg3:weatherData>
        </nrg3:WeatherStation>
      </nrg3:weatherStation>

      <!-- ───────────────────────── EPC ── -->

      <nrg3:energyPerformanceCertificate>
        <nrg3:EnergyPerformanceCertificate gml:id="id_L6_epc">
          <nrg3:certificationDate>2012-03-15</nrg3:certificationDate>
          <nrg3:rating codeSpace="epc_rating_codeSpace">B</nrg3:rating>
          <nrg3:value uom="kWh/(m^2*a)">75</nrg3:value>
          <nrg3:validUntilDate>2022-03-15</nrg3:validUntilDate>
        </nrg3:EnergyPerformanceCertificate>
      </nrg3:energyPerformanceCertificate>

      <!-- ───────────────────────── REFURBISHMENT MEASURE ── -->

      <nrg3:refurbishmentMeasure>
        <nrg3:RefurbishmentMeasure gml:id="id_L6_refurb">
          <nrg3:dateOfRefurbishment>2015-01-01</nrg3:dateOfRefurbishment>
          <nrg3:description>Roof insulation upgrade – PIR 200mm added</nrg3:description>
          <nrg3:level codeSpace="refurbishment_level_codeSpace">substantial</nrg3:level>
        </nrg3:RefurbishmentMeasure>
      </nrg3:refurbishmentMeasure>

      <!-- ───────────────────────── UTILITY NETWORK CONNECTIONS ── -->

      <nrg3:utilityNetworkConnection>
        <nrg3:UtilityNetworkConnection gml:id="id_L6_conn_gas">
          <nrg3:networkType codeSpace="network_type_codeSpace">naturalGas</nrg3:networkType>
          <nrg3:connectionType codeSpace="connection_type_codeSpace">connected</nrg3:connectionType>
        </nrg3:UtilityNetworkConnection>
      </nrg3:utilityNetworkConnection>

      <nrg3:utilityNetworkConnection>
        <nrg3:UtilityNetworkConnection gml:id="id_L6_conn_elec">
          <nrg3:networkType codeSpace="network_type_codeSpace">electricity</nrg3:networkType>
          <nrg3:connectionType codeSpace="connection_type_codeSpace">connected</nrg3:connectionType>
        </nrg3:UtilityNetworkConnection>
      </nrg3:utilityNetworkConnection>

      <nrg3:utilityNetworkConnection>
        <nrg3:UtilityNetworkConnection gml:id="id_L6_conn_dh">
          <nrg3:networkType codeSpace="network_type_codeSpace">districtHeating</nrg3:networkType>
          <nrg3:connectionType codeSpace="connection_type_codeSpace">disconnectedButConnectable</nrg3:connectionType>
        </nrg3:UtilityNetworkConnection>
      </nrg3:utilityNetworkConnection>

      <!-- ───────────────────────── DEVICES ── -->

      <!-- 1. Condensing gas boiler: 20 kW -->
      <nrg3:device>
        <nrg3:Boiler gml:id="id_L6_boiler">
          <gml:name>L6 Condensing Gas Boiler</gml:name>
          <nrg3:installedPower uom="W">20000</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.93</nrg3:nominalEfficiency>
          <nrg3:hasCondensation>true</nrg3:hasCondensation>
          <nrg3:energySource codeSpace="energy_source_codeSpace">naturalGas</nrg3:energySource>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L6_boiler_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">spaceHeating</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_heat_weekly"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:Boiler>
      </nrg3:device>

      <!-- 2. Ground-source heat pump: 10 kW, reversible, COP=4.2 -->
      <nrg3:device>
        <nrg3:HeatPump gml:id="id_L6_heatpump">
          <gml:name>L6 Ground-Source Heat Pump</gml:name>
          <nrg3:installedPower uom="W">10000</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">4.2</nrg3:nominalEfficiency>
          <nrg3:source codeSpace="hp_source_codeSpace">groundCoupled</nrg3:source>
          <nrg3:reversible>true</nrg3:reversible>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L6_hp_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">spaceHeating</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_heat_weekly"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:HeatPump>
      </nrg3:device>

      <!-- 3. Lighting – Zone1 south ground floor (50 m²) -->
      <nrg3:device>
        <nrg3:LightingDevice gml:id="id_L6_light_z1">
          <gml:description>LED luminaires – Zone1 south ground floor</gml:description>
          <gml:name>L6 Lighting Zone1</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 2.5 2.7</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:model>LED Panel 60x60</nrg3:model>
          <nrg3:numberOfDevices>5</nrg3:numberOfDevices>
          <nrg3:installedPower uom="W">500</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.92</nrg3:nominalEfficiency>
          <nrg3:heatDissipation uom="W/m^2">10</nrg3:heatDissipation>
          <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.59</nrg3:heatDissipationConvectiveFraction>
          <nrg3:heatDissipationLatentFraction uom="unit interval">0.00</nrg3:heatDissipationLatentFraction>
          <nrg3:heatDissipationRadiantFraction uom="unit interval">0.32</nrg3:heatDissipationRadiantFraction>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L6_light_z1_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">lighting</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_light_weekly"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:LightingDevice>
      </nrg3:device>

      <!-- 4. Lighting – Zone2 north ground floor (30 m²) -->
      <nrg3:device>
        <nrg3:LightingDevice gml:id="id_L6_light_z2">
          <gml:description>LED luminaires – Zone2 north ground floor</gml:description>
          <gml:name>L6 Lighting Zone2</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 6.5 2.7</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:model>LED Panel 60x60</nrg3:model>
          <nrg3:numberOfDevices>3</nrg3:numberOfDevices>
          <nrg3:installedPower uom="W">300</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.92</nrg3:nominalEfficiency>
          <nrg3:heatDissipation uom="W/m^2">10</nrg3:heatDissipation>
          <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.59</nrg3:heatDissipationConvectiveFraction>
          <nrg3:heatDissipationLatentFraction uom="unit interval">0.00</nrg3:heatDissipationLatentFraction>
          <nrg3:heatDissipationRadiantFraction uom="unit interval">0.32</nrg3:heatDissipationRadiantFraction>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L6_light_z2_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">lighting</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_light_weekly"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:LightingDevice>
      </nrg3:device>

      <!-- 5. Lighting – Zone3 first floor (80 m²) -->
      <nrg3:device>
        <nrg3:LightingDevice gml:id="id_L6_light_z3">
          <gml:description>LED luminaires – Zone3 first floor</gml:description>
          <gml:name>L6 Lighting Zone3</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 4 5.7</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:model>LED Panel 60x60</nrg3:model>
          <nrg3:numberOfDevices>8</nrg3:numberOfDevices>
          <nrg3:installedPower uom="W">800</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.92</nrg3:nominalEfficiency>
          <nrg3:heatDissipation uom="W/m^2">10</nrg3:heatDissipation>
          <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.59</nrg3:heatDissipationConvectiveFraction>
          <nrg3:heatDissipationLatentFraction uom="unit interval">0.00</nrg3:heatDissipationLatentFraction>
          <nrg3:heatDissipationRadiantFraction uom="unit interval">0.32</nrg3:heatDissipationRadiantFraction>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L6_light_z3_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">lighting</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_light_weekly"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:LightingDevice>
      </nrg3:device>

      <!-- 6. Movable shading device: internal blind on south windows -->
      <nrg3:device>
        <nrg3:MovableShadingDevice gml:id="id_L6_shading">
          <gml:description>Internal textile blind on south-facing windows</gml:description>
          <gml:name>L6 Internal Blind</gml:name>
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
            <nrg3:DeviceOperation gml:id="id_L6_shading_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">shading</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_shading_sched"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:MovableShadingDevice>
      </nrg3:device>

      <!-- 7. Solar thermal collector: flat plate, 8 m², south-facing 35° -->
      <nrg3:device>
        <nrg3:SolarThermalCollector gml:id="id_L6_stc">
          <gml:name>L6 Solar Thermal Collector</gml:name>
          <nrg3:collectorType codeSpace="collector_type_codeSpace">flatPlaneCollector</nrg3:collectorType>
          <nrg3:apertureArea uom="m^2">8</nrg3:apertureArea>
          <nrg3:opticalEfficiency uom="unit interval">0.78</nrg3:opticalEfficiency>
          <nrg3:thermalLossCoefficient1 uom="W/(m^2*K)">3.8</nrg3:thermalLossCoefficient1>
          <nrg3:thermalLossCoefficient2 uom="W/(m^2*K^2)">0.013</nrg3:thermalLossCoefficient2>
          <nrg3:azimuth uom="decimal degree">180</nrg3:azimuth>
          <nrg3:inclination uom="decimal degree">35</nrg3:inclination>
        </nrg3:SolarThermalCollector>
      </nrg3:device>

      <!-- 8. Photovoltaic collector: monocrystalline, 3 kWp, 18 m² -->
      <nrg3:device>
        <nrg3:PhotovoltaicCollector gml:id="id_L6_pvc">
          <gml:name>L6 Photovoltaic Array</gml:name>
          <nrg3:cellType codeSpace="cell_type_codeSpace">monocrystalline</nrg3:cellType>
          <nrg3:peakPower uom="W">3000</nrg3:peakPower>
          <nrg3:moduleArea uom="m^2">18</nrg3:moduleArea>
          <nrg3:azimuth uom="decimal degree">180</nrg3:azimuth>
          <nrg3:inclination uom="decimal degree">35</nrg3:inclination>
        </nrg3:PhotovoltaicCollector>
      </nrg3:device>

      <!-- 9. Thermal storage: hot water tank 300 L -->
      <nrg3:device>
        <nrg3:ThermalStorageDevice gml:id="id_L6_tsd">
          <gml:name>L6 Hot Water Storage Tank</gml:name>
          <nrg3:storageType codeSpace="storage_type_codeSpace">hotWaterTank</nrg3:storageType>
          <nrg3:storageVolume uom="m^3">0.3</nrg3:storageVolume>
          <nrg3:preparationTemperature uom="degrees Celsius">55</nrg3:preparationTemperature>
          <nrg3:thermalLossesFactor uom="W/K">0.5</nrg3:thermalLossesFactor>
        </nrg3:ThermalStorageDevice>
      </nrg3:device>

      <!-- 10. Electrical storage: battery 10 kWh -->
      <nrg3:device>
        <nrg3:ElectricalStorageDevice gml:id="id_L6_esd">
          <gml:name>L6 Battery Storage</gml:name>
          <nrg3:storageType codeSpace="storage_type_codeSpace">battery</nrg3:storageType>
          <nrg3:storageCapacity uom="kWh">10</nrg3:storageCapacity>
          <nrg3:nominalEfficiency uom="unit interval">0.92</nrg3:nominalEfficiency>
        </nrg3:ElectricalStorageDevice>
      </nrg3:device>

      <!-- 11. Generic device: Heat Recovery Ventilation unit -->
      <nrg3:device>
        <nrg3:GenericDevice gml:id="id_L6_hrv">
          <gml:name>L6 HRV Ventilation Unit</gml:name>
          <nrg3:model>HeatRecoveryVentilation</nrg3:model>
          <nrg3:installedPower uom="W">600</nrg3:installedPower>
          <nrg3:nominalEfficiency uom="unit interval">0.85</nrg3:nominalEfficiency>
          <nrg3:operation>
            <nrg3:DeviceOperation gml:id="id_L6_hrv_op">
              <nrg3:operationType codeSpace="op_type_codeSpace">ventilation</nrg3:operationType>
              <nrg3:schedule xlink:href="#id_L6_vent_weekly"/>
            </nrg3:DeviceOperation>
          </nrg3:operation>
        </nrg3:GenericDevice>
      </nrg3:device>

      <!-- ───────────────────────── USAGE ZONES ── -->

      <!-- Zone1 usage zone: south ground floor 50 m², 5 workers -->
      <nrg3:usageZone>
        <nrg3:UsageZone gml:id="id_L6_uz1">
          <gml:description>South ground-floor office usage zone</gml:description>
          <gml:name>L6 UsageZone1 South-GF</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 2.5 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">50</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:type codeSpace="usageZone_type_codeSpace">office</nrg3:type>
          <nrg3:occupiedBy>
            <nrg3:Occupants gml:id="id_L6_occ1">
              <gml:name>L6 Zone1 Occupants</gml:name>
              <nrg3:type codeSpace="occupants_type_codeSpace">workers</nrg3:type>
              <nrg3:numberOfOccupants>5</nrg3:numberOfOccupants>
              <nrg3:heatDissipation uom="W">80</nrg3:heatDissipation>
              <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.50</nrg3:heatDissipationConvectiveFraction>
              <nrg3:heatDissipationLatentFraction uom="unit interval">0.50</nrg3:heatDissipationLatentFraction>
              <nrg3:heatDissipationRadiantFraction uom="unit interval">0.30</nrg3:heatDissipationRadiantFraction>
              <nrg3:occupancyRate xlink:href="#id_L6_occ_weekly"/>
            </nrg3:Occupants>
          </nrg3:occupiedBy>
          <nrg3:internalHeatGains uom="W/m^2">20</nrg3:internalHeatGains>
          <nrg3:heatingSchedule xlink:href="#id_L6_heat_weekly"/>
          <nrg3:coolingSchedule xlink:href="#id_L6_cool_weekly"/>
          <nrg3:ventilationSchedule xlink:href="#id_L6_vent_weekly"/>
        </nrg3:UsageZone>
      </nrg3:usageZone>

      <!-- Zone2 usage zone: north ground floor 30 m², 3 workers -->
      <nrg3:usageZone>
        <nrg3:UsageZone gml:id="id_L6_uz2">
          <gml:description>North ground-floor office usage zone</gml:description>
          <gml:name>L6 UsageZone2 North-GF</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 6.5 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">30</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:type codeSpace="usageZone_type_codeSpace">office</nrg3:type>
          <nrg3:occupiedBy>
            <nrg3:Occupants gml:id="id_L6_occ2">
              <gml:name>L6 Zone2 Occupants</gml:name>
              <nrg3:type codeSpace="occupants_type_codeSpace">workers</nrg3:type>
              <nrg3:numberOfOccupants>3</nrg3:numberOfOccupants>
              <nrg3:heatDissipation uom="W">80</nrg3:heatDissipation>
              <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.50</nrg3:heatDissipationConvectiveFraction>
              <nrg3:heatDissipationLatentFraction uom="unit interval">0.50</nrg3:heatDissipationLatentFraction>
              <nrg3:heatDissipationRadiantFraction uom="unit interval">0.30</nrg3:heatDissipationRadiantFraction>
              <nrg3:occupancyRate xlink:href="#id_L6_occ_weekly"/>
            </nrg3:Occupants>
          </nrg3:occupiedBy>
          <nrg3:internalHeatGains uom="W/m^2">20</nrg3:internalHeatGains>
          <nrg3:heatingSchedule xlink:href="#id_L6_heat_weekly"/>
          <nrg3:coolingSchedule xlink:href="#id_L6_cool_weekly"/>
          <nrg3:ventilationSchedule xlink:href="#id_L6_vent_weekly"/>
        </nrg3:UsageZone>
      </nrg3:usageZone>

      <!-- Zone3 usage zone: first floor 80 m², 8 workers -->
      <nrg3:usageZone>
        <nrg3:UsageZone gml:id="id_L6_uz3">
          <gml:description>First-floor office usage zone</gml:description>
          <gml:name>L6 UsageZone3 First-Floor</gml:name>
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
            <nrg3:Occupants gml:id="id_L6_occ3">
              <gml:name>L6 Zone3 Occupants</gml:name>
              <nrg3:type codeSpace="occupants_type_codeSpace">workers</nrg3:type>
              <nrg3:numberOfOccupants>8</nrg3:numberOfOccupants>
              <nrg3:heatDissipation uom="W">80</nrg3:heatDissipation>
              <nrg3:heatDissipationConvectiveFraction uom="unit interval">0.50</nrg3:heatDissipationConvectiveFraction>
              <nrg3:heatDissipationLatentFraction uom="unit interval">0.50</nrg3:heatDissipationLatentFraction>
              <nrg3:heatDissipationRadiantFraction uom="unit interval">0.30</nrg3:heatDissipationRadiantFraction>
              <nrg3:occupancyRate xlink:href="#id_L6_occ_weekly"/>
            </nrg3:Occupants>
          </nrg3:occupiedBy>
          <nrg3:internalHeatGains uom="W/m^2">20</nrg3:internalHeatGains>
          <nrg3:heatingSchedule xlink:href="#id_L6_heat_weekly"/>
          <nrg3:coolingSchedule xlink:href="#id_L6_cool_weekly"/>
          <nrg3:ventilationSchedule xlink:href="#id_L6_vent_weekly"/>
        </nrg3:UsageZone>
      </nrg3:usageZone>

      <!-- ================================================================
           THERMAL ZONE 1 – South ground floor (x=[0,10], y=[0,5], z=[0,3])
           ================================================================ -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L6_tz1">
          <gml:description>South ground-floor zone, 10×5×3m = 50m², 150m³</gml:description>
          <gml:name>L6 Zone1 South-GF</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 2.5 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">50</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">150</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>
          <nrg3:heatCapacity uom="J/K">300000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.30</nrg3:infiltrationRate>
          <nrg3:isCooled>true</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- Ground slab z=0, y=[0,5] – outward -Z, CCW from below -->
          <nrg3:thermalBoundary>
            <bldg:GroundSurface gml:id="id_L6_z1_ground">
              <gml:name>Ground Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z1_ground">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 5 0 10 5 0 10 0 0 0 0 0 0 5 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_ground"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">50</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:GroundSurface>
          </nrg3:thermalBoundary>

          <!-- South wall y=0, z=[0,3] – 1 window x=[2,8] z=[0.8,2.4] -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z1_wall_south">
              <gml:name>South Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z1_south">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 0 10 0 0 10 0 3 0 0 3 0 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                      <!-- Window hole x=[2,8] z=[0.8,2.4] -->
                      <gml:interior>
                        <gml:LinearRing>
                          <gml:posList>2 0 0.8 2 0 2.4 8 0 2.4 8 0 0.8 2 0 0.8</gml:posList>
                        </gml:LinearRing>
                      </gml:interior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <!-- Window: 6×1.6 = 9.6 m² -->
              <bldg:opening>
                <bldg:Window gml:id="id_L6_z1_win1">
                  <gml:name>L6 Z1 South Window</gml:name>
                  <bldg:lod3MultiSurface>
                    <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:surfaceMember>
                        <gml:Polygon gml:id="id_L6_poly_z1_win1">
                          <gml:exterior>
                            <gml:LinearRing>
                              <gml:posList>2 0 0.8 8 0 0.8 8 0 2.4 2 0 2.4 2 0 0.8</gml:posList>
                            </gml:LinearRing>
                          </gml:exterior>
                        </gml:Polygon>
                      </gml:surfaceMember>
                    </gml:MultiSurface>
                  </bldg:lod3MultiSurface>
                  <nrg3:layeredConstruction xlink:href="#id_L6_lc_glazing"/>
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

          <!-- North internal wall y=5, z=[0,3] – adjacent to Z2 south internal wall -->
          <!-- Outward +Y from Z1; CCW from Z2-side (looking south) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z1_wall_north_int">
              <gml:name>North Internal Wall Z1 (adj Z2 south)</gml:name>
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L6_z2_wall_south_int</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z1_north_int">
                      <gml:exterior>
                        <gml:LinearRing>
                          <!-- outward +Y, CCW from north (+Y looking toward -Y) -->
                          <gml:posList>10 5 0 0 5 0 0 5 3 10 5 3 10 5 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_intwall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall x=10, y=[0,5], z=[0,3] – outward +X -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z1_wall_east">
              <gml:name>East Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z1_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 0 0 10 5 0 10 5 3 10 0 3 10 0 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">15</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall x=0, y=[0,5], z=[0,3] – outward -X -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z1_wall_west">
              <gml:name>West Wall Z1</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z1_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 5 0 0 0 0 0 0 3 0 5 3 0 5 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">270</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">15</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- Ceiling z=3, y=[0,5] – adjacent to Zone3 floor; outward +Z, CCW from above -->
          <nrg3:thermalBoundary>
            <bldg:CeilingSurface gml:id="id_L6_z1_ceiling">
              <gml:name>Ceiling Z1 (adj Z3 floor)</gml:name>
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L6_z3_floor</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z1_ceiling">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 3 10 0 3 10 5 3 0 5 3 0 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_intfloor"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">50</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:CeilingSurface>
          </nrg3:thermalBoundary>

        </nrg3:ThermalZone>
      </nrg3:thermalZone>

      <!-- ================================================================
           THERMAL ZONE 2 – North ground floor (x=[0,10], y=[5,8], z=[0,3])
           ================================================================ -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L6_tz2">
          <gml:description>North ground-floor zone, 10×3×3m = 30m², 90m³</gml:description>
          <gml:name>L6 Zone2 North-GF</gml:name>
          <nrg3:referencePoint>
            <gml:Point srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
              <gml:pos>5 6.5 1.5</gml:pos>
            </gml:Point>
          </nrg3:referencePoint>
          <nrg3:area>
            <nrg3:QualifiedArea>
              <nrg3:value uom="m^2">30</nrg3:value>
              <nrg3:type codeSpace="area_codeSpace">grossFloorArea</nrg3:type>
            </nrg3:QualifiedArea>
          </nrg3:area>
          <nrg3:volume>
            <nrg3:QualifiedVolume>
              <nrg3:value uom="m^3">90</nrg3:value>
              <nrg3:type codeSpace="volume_codeSpace">grossVolume</nrg3:type>
            </nrg3:QualifiedVolume>
          </nrg3:volume>
          <nrg3:heatCapacity uom="J/K">180000</nrg3:heatCapacity>
          <nrg3:infiltrationRate uom="1/h">0.30</nrg3:infiltrationRate>
          <nrg3:isCooled>true</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- Ground slab z=0, y=[5,8] – outward -Z -->
          <nrg3:thermalBoundary>
            <bldg:GroundSurface gml:id="id_L6_z2_ground">
              <gml:name>Ground Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z2_ground">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 10 8 0 10 5 0 0 5 0 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_ground"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:GroundSurface>
          </nrg3:thermalBoundary>

          <!-- South internal wall y=5, z=[0,3] – adjacent to Z1 north internal wall -->
          <!-- Outward -Y from Z2; CCW from Z1-side (looking north, -Y direction) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z2_wall_south_int">
              <gml:name>South Internal Wall Z2 (adj Z1 north)</gml:name>
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L6_z1_wall_north_int</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z2_south_int">
                      <gml:exterior>
                        <gml:LinearRing>
                          <!-- outward -Y, CCW from south (-Y looking toward +Y) -->
                          <gml:posList>0 5 0 10 5 0 10 5 3 0 5 3 0 5 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_intwall_rev"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">180</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- North party wall y=8, z=[0,3] – PartyWallSurface → adiabatic -->
          <nrg3:thermalBoundary>
            <bldg:PartyWallSurface gml:id="id_L6_z2_wall_north_party">
              <gml:name>North Party Wall Z2 (adiabatic)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z2_north_party">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 8 0 0 8 0 0 8 3 10 8 3 10 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>true</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:PartyWallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall x=10, y=[5,8], z=[0,3] – outward +X -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z2_wall_east">
              <gml:name>East Wall Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z2_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 5 0 10 8 0 10 8 3 10 5 3 10 5 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">9</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall x=0, y=[5,8], z=[0,3] – outward -X -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z2_wall_west">
              <gml:name>West Wall Z2</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z2_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 0 0 5 0 0 5 3 0 8 3 0 8 0</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">270</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">9</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- Ceiling z=3, y=[5,8] – adjacent to Zone3 floor; outward +Z, CCW from above -->
          <nrg3:thermalBoundary>
            <bldg:CeilingSurface gml:id="id_L6_z2_ceiling">
              <gml:name>Ceiling Z2 (adj Z3 floor)</gml:name>
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L6_z3_floor</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z2_ceiling">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 5 3 10 5 3 10 8 3 0 8 3 0 5 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_intfloor"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:CeilingSurface>
          </nrg3:thermalBoundary>

        </nrg3:ThermalZone>
      </nrg3:thermalZone>

      <!-- ================================================================
           THERMAL ZONE 3 – First floor (x=[0,10], y=[0,8], z=[3,6])
           ================================================================ -->
      <nrg3:thermalZone>
        <nrg3:ThermalZone gml:id="id_L6_tz3">
          <gml:description>First-floor zone spanning full footprint, 10×8×3m = 80m², 240m³</gml:description>
          <gml:name>L6 Zone3 First-Floor</gml:name>
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
          <nrg3:infiltrationRate uom="1/h">0.25</nrg3:infiltrationRate>
          <nrg3:isCooled>true</nrg3:isCooled>
          <nrg3:isHeated>true</nrg3:isHeated>
          <nrg3:coincidesWithLod2Hull>false</nrg3:coincidesWithLod2Hull>

          <!-- Floor z=3, y=[0,8] – spans full GF footprint; adj to Z1+Z2 ceilings -->
          <!-- Outward -Z from Zone3; CCW from below (reverse of roof winding) -->
          <nrg3:thermalBoundary>
            <bldg:CeilingSurface gml:id="id_L6_z3_floor">
              <gml:name>Floor Z3 (adj Z1+Z2 ceilings)</gml:name>
              <!-- References Z1 ceiling as representative adjacent surface -->
              <gen:stringAttribute name="adjacentSurface">
                <gen:value>id_L6_z1_ceiling</gen:value>
              </gen:stringAttribute>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z3_floor">
                      <gml:exterior>
                        <gml:LinearRing>
                          <!-- outward -Z, CCW from below: reverse of CCW-from-above -->
                          <gml:posList>0 8 3 10 8 3 10 0 3 0 0 3 0 8 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_intfloor"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">180</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:CeilingSurface>
          </nrg3:thermalBoundary>

          <!-- Roof z=6 – outward +Z, CCW from above -->
          <nrg3:thermalBoundary>
            <bldg:RoofSurface gml:id="id_L6_z3_roof">
              <gml:name>Roof Z3</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z3_roof">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 6 10 0 6 10 8 6 0 8 6 0 0 6</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_roof"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">-1</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">0</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfGroundViewFactor uom="unit interval">0</nrg3:bdgBdrySurfGroundViewFactor>
              <nrg3:bdgBdrySurfSkyViewFactor uom="unit interval">1</nrg3:bdgBdrySurfSkyViewFactor>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">80</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:RoofSurface>
          </nrg3:thermalBoundary>

          <!-- South wall y=0, z=[3,6] – 1 window x=[2,8] z=[3.8,5.4] -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z3_wall_south">
              <gml:name>South Wall Z3</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z3_south">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 0 3 10 0 3 10 0 6 0 0 6 0 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                      <!-- Window hole x=[2,8] z=[3.8,5.4] -->
                      <gml:interior>
                        <gml:LinearRing>
                          <gml:posList>2 0 3.8 2 0 5.4 8 0 5.4 8 0 3.8 2 0 3.8</gml:posList>
                        </gml:LinearRing>
                      </gml:interior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <!-- Window: 6×1.6 = 9.6 m² -->
              <bldg:opening>
                <bldg:Window gml:id="id_L6_z3_win1">
                  <gml:name>L6 Z3 South Window</gml:name>
                  <bldg:lod3MultiSurface>
                    <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                      <gml:surfaceMember>
                        <gml:Polygon gml:id="id_L6_poly_z3_win1">
                          <gml:exterior>
                            <gml:LinearRing>
                              <gml:posList>2 0 3.8 8 0 3.8 8 0 5.4 2 0 5.4 2 0 3.8</gml:posList>
                            </gml:LinearRing>
                          </gml:exterior>
                        </gml:Polygon>
                      </gml:surfaceMember>
                    </gml:MultiSurface>
                  </bldg:lod3MultiSurface>
                  <nrg3:layeredConstruction xlink:href="#id_L6_lc_glazing"/>
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

          <!-- North wall y=8, z=[3,6] – exterior (Zone3 north is outer facade) -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z3_wall_north">
              <gml:name>North Wall Z3 (exterior)</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z3_north">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 8 3 0 8 3 0 8 6 10 8 6 10 8 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">0</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">30</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- East wall x=10, y=[0,8], z=[3,6] – outward +X -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z3_wall_east">
              <gml:name>East Wall Z3</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z3_east">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>10 0 3 10 8 3 10 8 6 10 0 6 10 0 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
              <nrg3:bdgBdrySurfAzimuth uom="decimal degree">90</nrg3:bdgBdrySurfAzimuth>
              <nrg3:bdgBdrySurfInclination uom="decimal degree">90</nrg3:bdgBdrySurfInclination>
              <nrg3:bdgBdrySurfIsAdiabatic>false</nrg3:bdgBdrySurfIsAdiabatic>
              <nrg3:bdgBdrySurfOpeningToSurfaceRatio uom="unit interval">0</nrg3:bdgBdrySurfOpeningToSurfaceRatio>
              <nrg3:bdgBdrySurfTotalSurfaceArea uom="m^2">24</nrg3:bdgBdrySurfTotalSurfaceArea>
            </bldg:WallSurface>
          </nrg3:thermalBoundary>

          <!-- West wall x=0, y=[0,8], z=[3,6] – outward -X -->
          <nrg3:thermalBoundary>
            <bldg:WallSurface gml:id="id_L6_z3_wall_west">
              <gml:name>West Wall Z3</gml:name>
              <bldg:lod3MultiSurface>
                <gml:MultiSurface srsName="urn:ogc:def:crs,crs:EPSG::28992,crs:EPSG::5109" srsDimension="3">
                  <gml:surfaceMember>
                    <gml:Polygon gml:id="id_L6_poly_z3_west">
                      <gml:exterior>
                        <gml:LinearRing>
                          <gml:posList>0 8 3 0 0 3 0 0 6 0 8 6 0 8 3</gml:posList>
                        </gml:LinearRing>
                      </gml:exterior>
                    </gml:Polygon>
                  </gml:surfaceMember>
                </gml:MultiSurface>
              </bldg:lod3MultiSurface>
              <nrg3:layeredConstruction xlink:href="#id_L6_lc_wall"/>
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

