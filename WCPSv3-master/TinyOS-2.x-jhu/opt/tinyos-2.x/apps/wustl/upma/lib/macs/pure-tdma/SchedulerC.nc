configuration SchedulerC {
  provides{
    interface DynamicSchedule;
  }


}
implementation {

  components SchedulerP;
  components UsefulC;
  components math_functionC;

  DynamicSchedule = SchedulerP.DynamicSchedule;
  SchedulerP.Useful -> UsefulC.Useful;
  SchedulerP.math_function -> math_functionC.math_function;
}
