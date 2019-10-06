configuration IntegrateScheduleC {
  provides{
    interface IntegrateSchedule;
  }


}
implementation {
  components IntegrateScheduleP;


  IntegrateSchedule = IntegrateScheduleP.IntegrateSchedule;

  //Uplink Interface
  components UplinkScheduleC;
  IntegrateScheduleP.UplinkSchedule -> UplinkScheduleC;
  
}
