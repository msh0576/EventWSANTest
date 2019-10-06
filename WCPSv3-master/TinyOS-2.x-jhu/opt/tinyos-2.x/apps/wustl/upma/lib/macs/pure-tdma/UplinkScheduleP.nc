

//#include "TDMA_msg.h"
module UplinkScheduleP {
  provides{
    interface UplinkSchedule;
  }

  uses{
    interface Initial;
  }

}
implementation {


  uint8_t FM_r_index, FM_c_index;
  uint8_t gateway=0;

  //function
  void Array_least_deadline(uint8_t flow_character[TASK_NUMBER][TASK_SIZE], uint8_t out_flow_matrix[3][TASK_NUMBER]);
  void Array_least_deadline_flow(uint8_t least_deadline_matrix[3][TASK_NUMBER], uint8_t (*flow_character)[TASK_SIZE], uint8_t (*routing)[NODE_NUMBER], uint8_t out_Flow_matrix[TASK_NUMBER][NODE_NUMBER]);
  void Find_parent(uint8_t initial, uint8_t tmp_flow_root, uint8_t flow_root, uint8_t (*routing)[NODE_NUMBER], uint8_t Input_Flow_matrix[TASK_NUMBER][NODE_NUMBER]);
  void UplinkScheduling(uint8_t deadline_flow_matrix[3][TASK_NUMBER], uint8_t routing_flow_matrix[TASK_NUMBER][NODE_NUMBER], uint8_t out_flow_matrix[MAX_SHCEDULE_SIZE][11]);


  //output: uplink Matrix[max][11]
  async command uint8_t (* UplinkSchedule.matrix())[11]
  {
    static uint8_t Result_Uplink_Schedule[MAX_SHCEDULE_SIZE][11];
    uint8_t (*UplinkRouting)[NODE_NUMBER];
    uint8_t (*Flow_character)[TASK_SIZE];
    uint8_t Flow_matrix[3][TASK_NUMBER];
    uint8_t Routing_Flow_matrix[TASK_NUMBER][NODE_NUMBER];
    uint8_t i,j;

    UplinkRouting = call Initial.Uplink();
    Flow_character = call Initial.Flow_character();

    //Initialize Routing_Flow_matrix
    for(i=0; i<TASK_NUMBER; i++)
    {
      for(j=0; j<NODE_NUMBER; j++)
      {
        Routing_Flow_matrix[i][j] = 0;
      }
    }

    //Initialize Result_Uplink_Schedule
    for(i=0; i<MAX_SHCEDULE_SIZE; i++)
    {
      for(j=0; j<11; j++)
      {
        Result_Uplink_Schedule[i][j] = 0;
      }
    }

    /*
    //Test UplinkRouting
    printf("UplinkRouting:\n");
    for(i=0; i<NODE_NUMBER; i++)
    {
      for(j=0; j<NODE_NUMBER; j++)
      {
        printf("%d, ", UplinkRouting[i][j]);
      }
      printf("\n");
      //printf("%d, ", *(UplinkRouting + i));
    }
    printf("\n");
    */


    //Array flow according to least deadline
    Array_least_deadline(Flow_character, Flow_matrix);  //row: [0]:deadline, [1]: flow_id, [2]:flow_root // col: size=TASK_NUMBER

    //Array flow considering flow character and routing topology
    Array_least_deadline_flow(Flow_matrix, Flow_character, UplinkRouting, Routing_Flow_matrix);    //A matrix : 1row - first least deadline flow nodes , 2row - second least deadline flow nodes and so on.

    //a fianl total matrix such as slot, sender, receiver, channel, etc.
    UplinkScheduling(Flow_matrix, Routing_Flow_matrix, Result_Uplink_Schedule);


    /*
    //Test Flow_matrix
    printf("Test Flow_matrix: \n");
    for(i=0; i<3; i++)
    {
      for(j=0; j<TASK_NUMBER; j++)
      {
        printf("%d, ", Flow_matrix[i][j]);
      }
      printf("\n");
    }
    printf("\n");
    */

    /*
    //Test Result_Uplink_Schedule
    printf("Result_Uplink_Schedule: \n");
    for(i=0; i<MAX_SHCEDULE_SIZE; i++)
    {
      printf("line %d : ",i);
      for(j=0; j<11; j++)
      {
        printf("%d, ", Result_Uplink_Schedule[i][j]);
      }
      printf("\n");
    }
    printf("\n");
    */

    return Result_Uplink_Schedule;

  }


//array task according to least deadline
//row: [0]:deadline, [1]: flow_id, [2]:flow_root
//col: size=TASK_NUMBER

  void Array_least_deadline(uint8_t (*flow_character)[TASK_SIZE], uint8_t out_flow_matrix[3][TASK_NUMBER])
  {
    uint8_t (*tmp_flow_character)[TASK_SIZE];
    uint8_t FLOW_ROOT, FLOW_ID, FLOW_PERIOD, FLOW_DEADLINE;
    uint8_t DEAD, F_ID, F_ROOT;
    uint8_t tmp_deadline, least_dead_flowid, least_dead_flow_root, least_flow_index;
    uint8_t i,j;
    uint8_t count, flow_index;

    //[0]:flow root, [1]:flow id, [2]:P, [3]:D
    FLOW_ROOT = 0;
    FLOW_ID = 1;
    FLOW_PERIOD = 2;
    FLOW_DEADLINE = 3;

    //[0]:deadline, [1]: flow_id, [2]:flow_root
    DEAD = 0;
    F_ID = 1;
    F_ROOT = 2;

    tmp_flow_character = flow_character;

    /*  //Test input (flow_character) element
    printf("tmp_flow_character: ");
    for(i=0; i<TASK_NUMBER; i++)
    {
      for(j=0; j<TASK_SIZE; j++)
      {
        printf("%d, ", tmp_flow_character[i][j]);
      }
      printf("\n");
    }
    printf("\n");
    */

    //Array task according to least deadline
    for(count=0; count<TASK_NUMBER; count++)
    {
      tmp_deadline = 100;
      for(flow_index=0; flow_index<TASK_NUMBER; flow_index++)
      {
        if( tmp_flow_character[flow_index][FLOW_DEADLINE] != 100)
        {
          if( tmp_deadline - tmp_flow_character[flow_index][FLOW_DEADLINE] > 0)
          {
            tmp_deadline = tmp_flow_character[flow_index][FLOW_DEADLINE];
            least_dead_flowid = tmp_flow_character[flow_index][FLOW_ID];
            least_dead_flow_root = tmp_flow_character[flow_index][FLOW_ROOT];
            least_flow_index = flow_index;
          }
        }
      }
      tmp_flow_character[least_flow_index][FLOW_DEADLINE] = 100;
      out_flow_matrix[DEAD][count] = tmp_deadline;
      out_flow_matrix[F_ID][count] = least_dead_flowid;
      out_flow_matrix[F_ROOT][count] = least_dead_flow_root;
    }
  }


//A matrix : 1row - first least deadline flow nodes , 2row - second least deadline flow nodes and so on.
  void Array_least_deadline_flow(uint8_t least_deadline_matrix[3][TASK_NUMBER], uint8_t (*flow_character)[TASK_SIZE], uint8_t (*routing)[NODE_NUMBER], uint8_t out_Flow_matrix[TASK_NUMBER][NODE_NUMBER])
  {
    uint8_t FLOW_ROOT, FLOW_ID, FLOW_PERIOD, FLOW_DAEDLINE, FLOW_DESTINATION;
    uint8_t DEAD, F_ID, F_ROOT;
    uint8_t initial, tmp_flow_root, flow_index;
    uint8_t i,j;

    //[0]:flow root, [1]:flow id, [2]:P, [3]:D, [4]:destination
    FLOW_ROOT = 0;
    FLOW_ID = 1;
    FLOW_PERIOD = 2;
    FLOW_DAEDLINE = 3;
    FLOW_DESTINATION = 4;

    //the matrix arraied with least deadline (in least_deadline_matrix)
    //1-row:deadline, 2-row:flowid, 3-row:flow root
    DEAD = 0;
    F_ID = 1;
    F_ROOT = 2;

    FM_r_index = 0;
    FM_c_index = -1;

    for(flow_index = 0; flow_index < TASK_NUMBER; flow_index++)
    {
      initial = 0;
      tmp_flow_root = 0;
      Find_parent(initial, tmp_flow_root, flow_character[flow_index][FLOW_ROOT], routing, out_Flow_matrix);     //Find their parent node in routing matrix
    }

    /*
    //Test out_Flow_matrix
    printf("out_Flow_matrix: \n");
    for(i=0; i<TASK_NUMBER; i++)
    {
      for(j=0; j<NODE_NUMBER; j++)
      {
        printf("%d, ", out_Flow_matrix[i][j]);
      }
      printf("\n");
    }
    printf("\n");
    */
  }

  void Find_parent(uint8_t initial, uint8_t tmp_flow_root, uint8_t flow_root, uint8_t (*routing)[NODE_NUMBER], uint8_t Input_Flow_matrix[TASK_NUMBER][NODE_NUMBER])
  {
    uint8_t i,j;
    uint8_t check_parent, check_gateway;

    initial = initial + 1;
    check_gateway = 0;
    if(initial == 1)
    {
      tmp_flow_root = flow_root;
      FM_c_index=0;
    }

    for(check_parent=0; check_parent < NODE_NUMBER; check_parent++)
    {
      if(routing[tmp_flow_root][check_parent] != 0)
      {
        Input_Flow_matrix[FM_r_index][FM_c_index] = tmp_flow_root;
        tmp_flow_root = check_parent;
        FM_c_index = FM_c_index + 1;
        Find_parent(initial, tmp_flow_root, check_parent, routing, Input_Flow_matrix);
      }
      else
      {
        check_gateway = check_gateway + 1;
        if(check_gateway == NODE_NUMBER)
        {
          Input_Flow_matrix[FM_r_index][FM_c_index] = gateway;
          FM_r_index = FM_r_index + 1;
        }
      }
    }

    /*
    printf("Test Find_parent\n");
    printf("flow_root:%d\n", flow_root);

    printf("Input_Flow_matrix: \n");
    for(i=0; i<TASK_NUMBER; i++)
    {
      for(j=0; j<NODE_NUMBER; j++)
      {
        printf("%d ",Input_Flow_matrix[i][j]);
      }
    }
    printf("\n");


    printf("routing:\n");
    for(i=0; i<NODE_NUMBER; i++)
    {
      for(j=0; j<NODE_NUMBER; j++)
      {
        printf("%d, ", routing[i][j]);
      }
      printf("\n");
    }
    printf("\n");
    */
  }

//Make total uplink schedule matrix //
  void UplinkScheduling(uint8_t deadline_flow_matrix[3][TASK_NUMBER], uint8_t routing_flow_matrix[TASK_NUMBER][NODE_NUMBER], uint8_t out_flow_matrix[MAX_SHCEDULE_SIZE][11])
  {
    uint8_t DFM_DEAD, DFM_F_ID, DFM_F_ROOT;
    uint8_t SLOT, SENDER, RECEIVER, CHANNEL, ACCESS_TYPE, FLOW_TYPE, FLOW_ID, FLOW_ROOT, SEND_STATUS, LAST_HOP_STATUS, HOP_COUNT;
    //uint8_t tmp_deadline_flow_matrix[3][TASK_NUMBER];
    uint8_t i,j, slot;
    uint8_t flow_index, flow_sender_index, flow_receiver_index, hop_count_index;

    /*
    [0]:slot
    [1]:sender
    [2]:receiver
    [3]:channel
    [4]:Access Type        0:dedicated, 1: shared, 2: steal, 3: ack
    [5]:Flow Type          0: emergency, 1: regular
    [6]:Flow ID
    [7]: Flow root
    [8]: Send status in sendDone    0: no-ack, 1: acked
    [9]: Last Hop Status
    [10]: Hop count in the flow
    */

    //schedule index
    SLOT = 0;
    SENDER = 1;
    RECEIVER = 2;
    CHANNEL = 3;
    ACCESS_TYPE = 4;
    FLOW_TYPE = 5;
    FLOW_ID = 6;
    FLOW_ROOT = 7;
    SEND_STATUS = 8;
    LAST_HOP_STATUS = 9;
    HOP_COUNT = 10;

    //index of deadline_flow_matrix
    DFM_DEAD = 0;
    DFM_F_ID = 1;
    DFM_F_ROOT = 2;

    /*
    //copy deadline_flow_matrix
    for(i=0; i<3; i++)
    {
      for(j=0; j<TASK_NUMBER; j++)
      {
        tmp_deadline_flow_matrix[i][j] = deadline_flow_matrix[i][j];
      }
    }
    */

    //Set initial parameter index
    flow_index = 0;
    flow_sender_index = 0;
    flow_receiver_index = flow_sender_index + 1;
    hop_count_index = flow_sender_index + 1;

    for(slot=1; slot<MAX_SHCEDULE_SIZE; slot++)
    {
      //------Set up slot, flow id, flow root, sender, receiver, hop count
      out_flow_matrix[slot][SLOT] = slot; //set up slot
      out_flow_matrix[slot][FLOW_ID] = deadline_flow_matrix[DFM_F_ID][flow_index];    //set up flow id
      out_flow_matrix[slot][FLOW_ROOT] = deadline_flow_matrix[DFM_F_ROOT][flow_index] + NODE_OFFSET;    //set up flow root
      out_flow_matrix[slot][SENDER] = routing_flow_matrix[flow_index][flow_sender_index] + NODE_OFFSET;   //set up flow sender
      out_flow_matrix[slot][RECEIVER] = routing_flow_matrix[flow_index][flow_receiver_index] + NODE_OFFSET;   //set up flow receiver
      out_flow_matrix[slot][HOP_COUNT] = hop_count_index;

      //-------common elements setup
      out_flow_matrix[slot][CHANNEL] = 22;          //channel
      out_flow_matrix[slot][ACCESS_TYPE] = 0;       //access type: TDMA
      out_flow_matrix[slot][FLOW_TYPE] = 1;         //flow type: regular
      out_flow_matrix[slot][SEND_STATUS] = 0;       //send status
      out_flow_matrix[slot][LAST_HOP_STATUS] = 0;   //last hop status

      //-----Next flow schedule
      if(routing_flow_matrix[flow_index][flow_receiver_index] == 0)
      {
        flow_index = flow_index + 1;

        //index initialization
        flow_sender_index = 0;
        flow_receiver_index = flow_sender_index + 1;
        hop_count_index = flow_sender_index + 1;

        if(flow_index >= TASK_NUMBER)
            break; //Scheduling is finished
      }else
      {
        flow_sender_index = flow_sender_index + 1;
        flow_receiver_index = flow_sender_index + 1;
        hop_count_index = flow_sender_index + 1;
      }
    }
  }

}
