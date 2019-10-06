

module IntegrateScheduleP {
  provides{
    interface IntegrateSchedule;
  }

  uses{
    interface UplinkSchedule;
  }

}
implementation {


  async command uint8_t (* IntegrateSchedule.TotalSchedule())[11]
  {
    static uint8_t (* Result_Integrate_Schedule)[11];
    uint8_t i,j;

    //Build uplink schedule matrix
    Result_Integrate_Schedule = call UplinkSchedule.matrix();

    /*
    //-----Test Result_Integrate_Schedule
    printf("Result_Integrate_Schedule: \n");
    for(i=0; i<MAX_SHCEDULE_SIZE; i++)
    {
      printf("line %d : ",i);
      for(j=0; j<11; j++)
      {
        printf("%d, ", Result_Integrate_Schedule[i][j]);
      }
      printf("\n");
    }
    printf("\n");
    */

    return Result_Integrate_Schedule;
  }

}
