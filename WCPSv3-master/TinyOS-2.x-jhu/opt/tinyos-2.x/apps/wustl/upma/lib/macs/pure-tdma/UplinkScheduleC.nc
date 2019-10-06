configuration UplinkScheduleC {
  provides{
    interface UplinkSchedule;
  }

}
implementation {
  components UplinkScheduleP;

  UplinkSchedule = UplinkScheduleP;

  components InitialC;
  UplinkScheduleP.Initial -> InitialC;
}
