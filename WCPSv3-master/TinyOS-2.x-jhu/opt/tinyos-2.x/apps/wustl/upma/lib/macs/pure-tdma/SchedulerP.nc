
module SchedulerP {
  provides{
    interface DynamicSchedule;
  }

  uses{
    interface Useful;
    interface math_function;
  }

}
implementation {

/****************************************************************
*      want to identify whether each task is allocated in a slot,
*      debug at &&*
*
*/
//*******************************************************************

  uint8_t TaskNumber = 3;   //***
  uint8_t CharacterNumber = 4;

  uint8_t TASK = 0;
  uint8_t PERIOD = 1;
  uint8_t DEADLINE = 2;
  uint8_t REMAINHOP = 3;

  uint8_t Channel_num = 1;




  uint8_t LeastDeadline(uint8_t* Pkt_deadline_list, uint8_t* Remainhop_list);
  void DeadlineList(uint8_t Pkt_deadline[][CharacterNumber]);
  void TaskList(uint8_t Pkt_Task[][CharacterNumber]);
  void RemainhopList(uint8_t Pkt_Task[][CharacterNumber]);
  //void ScheduleEDF(uint8_t schedule_len);
  void ScheduleEDF(uint32_t Superframe, uint8_t Task_character[][CharacterNumber]);
  //uint32_t FindTask(uint8_t flowid, uint8_t hopcount, uint32_t Superframe);

  //***  3 == TaskNumber
  uint8_t tmpDeadlineList[3]; //***
  uint8_t TotalTaskList[3]; //***
  uint8_t tmpRemainhopList[3];  //***
  uint8_t LeastDeadline_Task[3];
  uint8_t schedule[40];   //*** 40 ==(Superframe_len)
  uint8_t hop_count[40];  //*** 40 ==(Superframe_len)
  //*** 3 == TaskNumber
  uint8_t InitialDeadlineList[3];  //***
  uint8_t InitialTotalTaskList[3]; //***
  uint8_t InitialRemainhopList[3]; //***

  async command void DynamicSchedule.Initial(uint8_t Task_character[][4], uint32_t Superframe)    //[0]: Taskid,  [1]: Pkt period,  [2]: Pkt Deadline,  [3]: remain hop
  {
    uint8_t i;

    DeadlineList(Task_character);
    TaskList(Task_character);
    RemainhopList(Task_character);
    //
    for(i=0; i<TaskNumber; i++)
    {
      InitialDeadlineList[i] = tmpDeadlineList[i];
      InitialTotalTaskList[i] = TotalTaskList[i];
      InitialRemainhopList[i] = tmpRemainhopList[i];
    }
    //
    LeastDeadline(tmpDeadlineList, tmpRemainhopList);
    //ScheduleEDF(schedule_len);
    ScheduleEDF(Superframe, Task_character);

  }


  async command uint32_t DynamicSchedule.MakeSF(uint8_t Task_character[][4], uint8_t TaskNumber)
  {
    uint8_t i;
    uint8_t ans;

    ans = Task_character[0][PERIOD];

    for(i=0; i<TaskNumber-1; i++)
    {
      //printf("math_function.lmc(%u, %u)=%u\n",ans, Task_character[i+1][PERIOD]);
      ans = call math_function.lcm(ans, Task_character[i+1][PERIOD]);
      //printf("Task_character[%u][PERIOD]=%u\n", i, Task_character[i][PERIOD]);
    }
    return ans;
  }

  async command void DynamicSchedule.Scheduler(uint8_t Schedule[][11], uint32_t Superframe)
  {
    uint8_t i,j;
    uint32_t slot;

    slot = 0;
    i=0;

    //slot = FindTask(flowid, hopcount, Superframe);


    for(i=1; i<Superframe+1; i++)
    {
      Schedule[i-1][0] = i;                   //slot
      Schedule[i-1][6] = schedule[i];         //flowid
      Schedule[i-1][10] = hop_count[i];       //hopcount;

      Schedule[i-1][3] = 22; //channels
      Schedule[i-1][4] = 0;   //Accesstype : TDMA
      Schedule[i-1][5] = 1;   //flowtype: regular
      Schedule[i-1][8] = 0;    //send status
      Schedule[i-1][9] = 0;   //last hop status
    }


    for(i=0; i<TaskNumber; i++)
    {
      tmpDeadlineList[i] = InitialDeadlineList[i];
      TotalTaskList[i] = InitialTotalTaskList[i];
      tmpRemainhopList[i] = InitialRemainhopList[i];
    }

    //printf("End DynamicSchedule\n");

  }




///////////////////////////////////////////////////////////////
  //Deadline - Remainhop
  uint8_t LeastDeadline(uint8_t* Pkt_deadline_list, uint8_t* Remainhop_list)
  {
    uint8_t current_min_deadline_index = 0;
    uint8_t i = 0;
    uint8_t tmpPkt_deadline;
    uint8_t tmp[10];  //*** TaskNumber

    for(i=0; i<TaskNumber; i++)
    {
      //tmp[i] = Pkt_deadline_list[i] - Remainhop_list[i];
      tmp[i] = Pkt_deadline_list[i];
    }
    //printf("deadline - remainhop = %u, %u, %u\n",tmp[0],tmp[1],tmp[2]);

    tmpPkt_deadline = 100;
    //printf("tmpPkt_deadline: %u\n",tmpPkt_deadline);
    for(i=0; i<TaskNumber; i++)
    {
      if(tmpPkt_deadline - tmp[i] >= 0)
      {
        tmpPkt_deadline = tmp[i];
        current_min_deadline_index = i;
      }
    }

    //LeastDeadline_Task[0] = tmpPkt_deadline;
    //LeastDeadline_Task[1] = current_min_deadline_index;
    return current_min_deadline_index;
  }// return [0]:deadline, [1]:index
///////////////////////////////////////////////////////////////////////////
  void RemainhopList(uint8_t Pkt_Task[][CharacterNumber])
  {
    uint8_t i=0;

    for(i;i<TaskNumber;i++)
    {
      tmpRemainhopList[i] = Pkt_Task[i][REMAINHOP];
      //printf("tmpRemainhopList[%u]: %u\n",i, tmpRemainhopList[i]);
    }

  }
//////////////////////////////////////////////////////////////////////////////
  void DeadlineList(uint8_t Pkt_deadline[][CharacterNumber])
  {
    uint8_t i=0;

    for(i;i<TaskNumber;i++)
    {
      tmpDeadlineList[i] = Pkt_deadline[i][DEADLINE];
      //printf("tmpDeadlineList[%u]: %u\n",i,tmpDeadlineList[i]);
    }



  }//return integrated deadline of all tasks



//////////////////////////////////////////////////////////////////////////////
  void TaskList(uint8_t Pkt_Task[][CharacterNumber])
  {
    uint8_t i=0;

    //printf("TaskList:");
    for(i=0;i<TaskNumber;i++)
    {
      TotalTaskList[i] = Pkt_Task[i][TASK];
      //printf("TotalTaskList[%u]: %u\n", i, TotalTaskList[i]);
    }
    //printf("\n");
    //printf("All Task List=> %u, %u, %u\n", TotalTaskList[0], TotalTaskList[1], TotalTaskList[2]);

  }//return integrated task id of all tasks




/////////////////////////////////////////////////////////////////////////////


void ScheduleEDF(uint32_t Superframe, uint8_t Task_character[][CharacterNumber])
{
  uint8_t slot = 0;
  uint8_t i = 0;
  uint8_t index = 0;

  //printf("EDF schedule[slot]: ");
  for(slot = 1; slot < Superframe+1; slot++)
  {
    //printf("slot: %u\n",slot);


    //index = call
    if(TotalTaskList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] != 100)       //check available task
    {
      schedule[slot] = TotalTaskList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)];                    //least EDF task allocation at Schedule[slot]
      tmpRemainhopList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] = tmpRemainhopList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] - 1;    //decrease remain hop
      hop_count[slot] = InitialRemainhopList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] - tmpRemainhopList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)];

      //printf("id: %u  LeastDeadline_Task : %u \n", TOS_NODE_ID, LeastDeadline(tmpDeadlineList,tmpRemainhopList));
      //&&*
      //printf("id: %u   schedule Task: %u at %u  remainhop to destination: %u\n",TOS_NODE_ID,schedule[slot], slot, tmpRemainhopList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)]);
      //printf("hop_count[%u]: %u\n", slot, hop_count[slot]);
      //&&*

      if(tmpRemainhopList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] == 0)            //check last hop
      {

        TotalTaskList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] = 100;                              //remove task  in TotalTaskList
        tmpDeadlineList[LeastDeadline(tmpDeadlineList,tmpRemainhopList)] = 100;                             //remove deadline


        LeastDeadline(tmpDeadlineList, tmpRemainhopList);      //recalculate leastdeadline without TotalTaskList == 100 !
        //printf("id: %u  LeastDeadline_Task : [0]%u   [1]:%u \n", TOS_NODE_ID, LeastDeadline_Task[0], LeastDeadline(tmpDeadlineList,tmpRemainhopList));

      }

    }else
    {
      //printf("dummy at slot:%u!\n",slot);
      schedule[slot] = 100;
    }

    /*
    for(i=0;i<TaskNumber;i++)
    {
      printf("TotalTaskList[%u]: %u\n", i, TotalTaskList[i]);
    }
    */  //&&

    for(i=0;i<TaskNumber;i++)
    {
      //printf("slot: %u, Task_character[i][PERIOD]:%u \n",slot, Task_character[i][PERIOD]);
      if(slot % Task_character[i][PERIOD] == 0)
      {
        TotalTaskList[i] = InitialTotalTaskList[i];
        tmpDeadlineList[i] = InitialDeadlineList[i];
        tmpRemainhopList[i] = InitialRemainhopList[i];
      }
    }


  }
  /*
  for(slot = 1; slot < Superframe+1; slot++)
  {
    printf("schedule[%u]: %u\n",slot, schedule[slot]);
  }
  */
}

//////////////////////////////////////////////////////////////////////////////////////////////
/*
  uint32_t FindTask(uint8_t flowid, uint8_t hopcount, uint32_t Superframe)
  {
    uint8_t i;
    uint32_t slot = 0;
    uint8_t tmphopcount = 0;

    tmphopcount = hopcount;

    for(i=1; i<Superframe+1; i++)
    {
      if((tmphopcount != 1) && (schedule[i] == flowid))
      {
        tmphopcount = tmphopcount - 1;
      }else if((schedule[i] == flowid) && (tmphopcount == 1))   //find slot according to flow id, hopcount
      {
        slot = i;
        //printf("&current slot: %u\n",slot);
        break;
      }else   //can't find slot
      {
        slot = 100;
      }


    }

    //printf("slot: %u  , flowid: %u  , hopcount:%u\n",slot,flowid,hopcount);

    //return slot according to flowid and hopcount
    return slot;
  }
*/


}
