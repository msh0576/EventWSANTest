module UsefulP {
  provides{
    interface Useful;
  }
}
implementation {

  //uint8_t CharacterNumber = 3;
  uint8_t TaskNumber = 3;
  uint8_t DEADLINE = 2;

  //used by TaskSenderReceiver function.
  uint8_t FLOWID = 0;
  uint8_t SENDER = 1;
  uint8_t RECEIVER = 2;
  uint8_t HOPCOUNT = 3;

  uint8_t NetworkRoute[7][7]={      //***NodeNumber
  {0,0,1,0,1,0,1},
  {0,0,1,1,1,0,0},
  {1,1,0,1,1,0,0},
  {0,1,1,0,1,1,1},
  {1,1,1,1,0,1,1},
  {0,0,0,1,1,0,1},
  {1,0,0,1,1,1,0}
  };

  uint8_t makeroute[7][7]={         //*** 7==NodeNumber
  {0,0,0,0,0,0,0,0},    //0
  {0,0,1,0,0,0,0,0},
  {1,0,0,0,0,0,0,0},
  {0,0,0,0,1,0,0,0},
  {1,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,1,0},    //5
  {1,0,0,0,0,0,0,0}
  //{0,0,0,0,0,0,0,0,0,1,0},
  //{0,0,0,0,0,0,0,0,0,0,1},
  //{1,0,0,0,0,0,0,0,0,0,0},
  //{1,0,0,0,0,0,0,0,0,0,0}
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////////
  async command void Useful.SetSR(uint8_t schedule[][11], uint8_t transmission_type, uint8_t flowid, uint8_t hopcount, uint32_t Superframe)  // ***7==NodeNumber
  {
    uint8_t Nodeoffset = 10;  //&&
    uint8_t NodeNumber = 7;     //***
    uint8_t sender, receiver;
    uint8_t i,j;
    uint8_t tmp;
    uint8_t max_flow_len;
    uint8_t flow[3] = {0,0,0};  //***3 == max_flow_len      ex. 1->2->3   {1,2,3}
    uint8_t data_totalflow[3][5] = {  //***first "3" == Flow(Task) Nummber, second "3" == max_flow_len
    {1,2,0},    //flow 1 routing path
    {3,4,0},    //flow 2 routing path
    {5,6,0}
    };
    uint8_t control_totalflow[2][5] = {   //***
    {0,2,1},
    {0,6,5,4,3}
    //{0,10,8,6,5}
    };

    max_flow_len = 3;     //***
    sender = 0;
    receiver = 0;
    tmp = 0;


    if(transmission_type == 1)    //1==data transmission
    {
      if(flowid == 1)               //***NodeNumber
      {
        for(i=0;i<max_flow_len;i++)
        {
          flow[i] = data_totalflow[flowid-1][i];
        }
        if((hopcount == 1) || (hopcount == 2))        //*** Need to revise when you change network topology, ex. hopcount = 2 , in case of 1->2->3
        {
          if(makeroute[flow[hopcount-1]][flow[hopcount]] == 1)
          {
            sender = flow[hopcount-1];
            receiver = flow[hopcount];
          }else
          {
            printf("error in makeroute!\n");
            sender = 0;
            receiver = 0;
          }

        }else
        {
          printf("Check hopcount in SetSR!\n");
          sender = 0;
          receiver = 0;
        }

      }else if(flowid == 2)       //***
      {
        for(i=0;i<max_flow_len;i++)
        {
          flow[i] = data_totalflow[flowid-1][i];
        }
        if((hopcount == 1) || (hopcount == 2))    //***       //  || (hopcount == 3)|| (hopcount == 4)
        {
          if(makeroute[flow[hopcount-1]][flow[hopcount]] == 1)
          {
            sender = flow[hopcount-1];
            receiver = flow[hopcount];
          }else
          {
            printf("error in makeroute!\n");
            sender = 0;
            receiver = 0;
          }
        }else
        {
          printf("Check hopcount in SetSR!\n");
          sender = 0;
          receiver = 0;
        }
      }
      else if(flowid == 3)   //***
      {
        for(i=0;i<max_flow_len;i++)
        {
          flow[i] = data_totalflow[flowid-1][i];
        }
        if((hopcount == 1) || (hopcount == 2))   //***          //  || (hopcount == 3)|| (hopcount == 4)
        {
          if(makeroute[flow[hopcount-1]][flow[hopcount]] == 1)
          {
            sender = flow[hopcount-1];
            receiver = flow[hopcount];
          }else
          {
            printf("error in makeroute!\n");
            sender = 0;
            receiver = 0;
          }
        }else
        {
          printf("Check hopcount in SetSR!\n");
          sender = 0;
          receiver = 0;
        }
      }
      else
      {
        sender = 0;
        receiver = 0;
      }

    }

    //allocate sender, receiver, flow root in schedule
    for(i=1; i<Superframe+1; i++)
    {
      if(schedule[i][6] == flowid && schedule[i][10] == hopcount)
      {
        schedule[i][1] = sender + Nodeoffset;
        schedule[i][2] = receiver + Nodeoffset;
      }
    }

    for(i=1; i<Superframe+1; i++)
    {
      if(schedule[i][6] == flowid && schedule[i][10] == 1)
      {
        for(j=1; j<Superframe+1; j++)
        {
          if(schedule[j][6]==flowid)
            schedule[j][7] = schedule[i][1];
        }
      }
    }

  }

  /*
  void Make_flow_routing_path(uint8_t node_topology[][7], uint8_t flow_root, uint8_t destination ,uint8_t NodeNumber) //***7==NodeNumber
  {
    uint8_t flow_path[][];
    uint8_t i,j;
    uint8_t tmpNode, tmpReceiver;

    tmpNode = flow_root;

    for(i=0; i<NodeNumber; i++)
    {
      for(j=0; j<NodeNumber; j++)
      {
        if(node_topology[tmpNode][j] == 1)
        {
          tmpReceiver = j;
        }else
        {
          tmpReceiver = 100;
        }
      }
      if((tmpReceiver == 100) || (tmpReceiver == destination))
        break;
      flow_path[i]=tmpNode;
      tmpNode = tmpReceiver;
    }


  }
  */

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////


    /*
    async command uint8_t* Useful.DeadlineList(uint8_t Pkt_Character[3])
    {
      uint8_t i;
      uint8_t rtn[TaskNumber];

      for(i;i<TaskNumber;i++)
      {
        rtn[i] = Pkt_Character[DEADLINE];
      }

      printf("DeadlineList is operated successfully!\n");

      return rtn;

    }//return integrated deadline of all tasks

    async command uint8_t* Useful.TaskSenderReceiver(uint8_t flowid, uint8_t hopcount)
    {
      uint8_t sender;
      uint8_t receiver;
      uint8_t rtn[2];


      if(flowid == 1 && hopcount == 1)
      {
        sender = 11;
        receiver = 12;
      }else if(flowid == 1 && hopcount == 2)
      {
        sender = 12;
        receiver = 10;
      }else if(flowid == 2 && hopcount == 1)
      {
        sender = 13;
        receiver = 14;
      }else if(flowid == 2 && hopcount == 2)
      {
        sender = 14;
        receiver = 10;
      }else if(flowid == 3 && hopcount == 1)
      {
        sender = 15;
        receiver = 16;
      }else if(flowid == 3 && hopcount == 2)
      {
        sender = 16;
        receiver = 10;
      }else
      {
        sender = 100;
        receiver = 100;
      }

      rtn[0]=sender;
      rtn[1]=receiver;


      //printf("TaskSenderReceiver=> rtn[0]: %u, rtn[1]: %u, rtn[2]: %u, rtn[3]: %u\n",rtn[0],rtn[1],rtn[2],rtn[3]);
      return rtn;
      //retrun [0]:sender  [1]:receiver
    }


    async command void Useful.MakeRoute(uint8_t transmission_type, uint8_t graph[][7])  //***7 == NodeNumber
    {
      uint8_t NodeNumber = 7;     //***
      uint8_t IDoffset = 10;
      uint8_t i,j;
      uint8_t rtn[7][7];    //***





      if(transmission_type == 1)  //data transmission
      {
        for(i=0; i<NodeNumber; i++)
        {
          for(j=0; j<NodeNumber; j++)
          {
            graph[i][j] = makeroute[i][j];
          }
          //printf("data transmission route: [%u]: {%u,%u,%u,%u,%u,%u,%u}\n",i,graph[i][0],graph[i][1],graph[i][2],graph[i][3],graph[i][4],graph[i][5],graph[i][6]);

        }
      }else   //control transmission
      {
      for(i=0; i<NodeNumber; i++)
      {
        for(j=0; j<NodeNumber; j++)
        {
          graph[i][j] = makeroute[j][i];
        }
        //printf("data transmission route: [%u]: {%u,%u,%u,%u,%u,%u,%u}\n",i,rtn[i][0],rtn[i][1],rtn[i][2],rtn[i][3],rtn[i][4],rtn[i][5],rtn[i][6]);
      }
      }


      //printf("makeroute: %u, %u, %u\n",*(*(*(graph+0)+1)),*(*(*(graph+0)+1)), *(*(*(graph+0)+1)));


      //return rtn;
    }
    */



}
