/*
 * "Copyright (c) 2007 Washington University in St. Louis.
 * All rights reserved.
 * @author Bo Li
 * @date $Date: 2014/10/17
 */


#include "TDMA_msg.h"
module PureTDMASchedulerP {
	provides {
		interface Init;
		interface SplitControl;
		interface AsyncSend as Send;
		interface AsyncReceive as Receive;
		interface CcaControl[am_id_t amId];
		interface FrameConfiguration as Frame;
	}
	uses{
		interface AsyncStdControl as GenericSlotter;
		interface RadioPowerControl;
		interface Slotter;
		interface SlotterControl;
		interface FrameConfiguration;
		interface AsyncSend as SubSend;
		interface AsyncSend as BeaconSend;
		interface AsyncReceive as SubReceive;
		interface AMPacket;
		interface Resend;
		interface PacketAcknowledgements;
		interface Boot;
		interface Leds;
		//interface HplMsp430GeneralIO as Pin;

		interface CC2420Config;//Added by Bo
		interface TossimPacketModelCCA;
		interface TossimComPrintfWrite;
		interface SimMote;


    //Test
    interface IntegrateSchedule;
	}
}
implementation {
	enum {
		SIMPLE_TDMA_SYNC = 123,
	};
	bool init;
	uint32_t slotSize;
	uint32_t bi, sd, cap;
	uint8_t coordinatorId;

	message_t *toSend; //this one will become critical later on, and cause segmentation error
	uint8_t toSendLen;

	//Below added by Bo
	message_t packet;

	uint8_t get_last_hop_status(uint8_t flow_id_t, uint8_t access_type_t, uint8_t hop_count_t);
	void set_current_hop_status(uint32_t slot_t, uint8_t sender, uint8_t receiver);
	void set_send_status(uint32_t slot_at_send_done, uint8_t ack_t);
	void set_send (uint32_t slot_t);
	uint8_t get_flow_id(uint32_t slot_t, uint8_t sender, uint8_t receiver);

  	//0 Slot
  	//1 Sender
  	//2 Receiver
  	//3 Channel
  	//4 Access Type:    0: dedicated,  1: shared, 2: steal, 3: ack
  	//5 Flow Type:      0: emergency, 1: regular
  	//6 Flow ID:        1, 2
  	//7 Flow root: root of the flow, i.e., sensor that launch the communcation
  	//8 Send status in sendDone: 0: no-ack, 1: acked
  	//9 Last Hop Status:
  	//10 Hop count in the flow

    /*
    uint8_t schedule[MAX_SHCEDULE_SIZE][11]={//Source Routing, 16 sensor topology, 2 prime trans, retrans twice, baseline. //***   12 == # of total hopcount
    	//flow 11, flow sensor
    	{1, 11, 10, 22, 0, 1, 1, 11, 0, 0, 1},
    	{3, 12, 10, 22, 0, 1, 2, 12, 0, 0, 1}


    	};
      */


  uint8_t (* schedule)[11];



	uint8_t schedule_len=MAX_SHCEDULE_SIZE;   //***
  uint32_t gigaframe_length = 5 + 1; //5Hz at most     //***  18 == schedule_len + controlschedule_len +1         //SF + controlschedule_len+1

  uint8_t controlschedule_len = 8;    //*** 8 == NodeNumber + 1(calculate period)
  uint8_t controlschedule_start = 11;    //*** 11 == schedule_len + 1;


	bool sync;
	bool requestStop;
	uint32_t sync_count = 0;

	event void Boot.booted(){


  }


	command error_t Init.init() {
    uint8_t i, j;


		slotSize = 10 * 32;     //10ms
		bi = 40000; //# of slots in the supersuperframe with only one slot 0 doing sync
		sd = 40000; //last active slot
		cap = 0; // what is this used for? is this yet another superframe length?


		coordinatorId = 0;
		init = FALSE;
		toSend = NULL;
		toSendLen = 0;
		sync = FALSE;
		requestStop = FALSE;
		call SimMote.setTcpMsg(0, 0, 0, 0, 0); //reset TcpMsg

    call SimMote.setSendNodeIDMsg(0); //reset SendTimeMsg

    printf("ID:%u   and   gigaframe_length:%u\n", TOS_NODE_ID, gigaframe_length);

    //------Set schedule matrix
    schedule = call IntegrateSchedule.TotalSchedule();


    //-----Test Schedule matrix
    printf("schedule:\n");
    for(i=0; i<schedule_len; i++)
    {
      printf("[%u]: {%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u}\n",i, schedule[i][0],schedule[i][1],schedule[i][2],schedule[i][3],schedule[i][4],schedule[i][5],schedule[i][6],schedule[i][7],schedule[i][8],schedule[i][9],schedule[i][10]);
    }


		return SUCCESS;
	}

 	command error_t SplitControl.start() {
 		error_t err;
 		if (init == FALSE) {
 			call FrameConfiguration.setSlotLength(slotSize);
 			call FrameConfiguration.setFrameLength(bi + 1);
 			//call FrameConfiguration.setFrameLength(1000);
 		}
 		err = call RadioPowerControl.start();
 		return err;
 	}

 	command error_t SplitControl.stop() {
 		printf("This is sensor: %u and the SplitControl.stop has been reached\n", TOS_NODE_ID);
 		requestStop = TRUE;
 		call GenericSlotter.stop();
 		call RadioPowerControl.stop();
 		return SUCCESS;
 	}

 	event void RadioPowerControl.startDone(error_t error) {
 	 	int i;
 		if (coordinatorId == TOS_NODE_ID) {
 			if (init == FALSE) {
 				signal SplitControl.startDone(error); //start sensor 0
 				call GenericSlotter.start(); //start slot counter
 				call SlotterControl.synchronize(0); //synchronize the rest sensors in the network
 				init = TRUE;
 			}
 		} else {
 			if (init == FALSE) {
 				signal SplitControl.startDone(error); //start all non-zero sensors
 				init = TRUE; //initialization done
 			}
 		}
	}

 	event void RadioPowerControl.stopDone(error_t error)  {
		if (requestStop)  {
			printf("This is sensor: %u and the RadioPowerControl.stopDone has been reached\n", TOS_NODE_ID);
			requestStop = FALSE;
			signal SplitControl.stopDone(error);
		}
	}

 	/****************************
 	 *   Implements the schedule
 	 */
 	async event void Slotter.slot(uint32_t slot) {
 		message_t *tmpToSend;
 		uint8_t tmpToSendLen;
 		uint8_t i;
    uint8_t Nodeoffset = 10;    //***
    uint8_t tmp_Event1 = 0;
    uint8_t tmp_Event2 = 0;

    //printf("id: %u  , Current Slot: %u\n",TOS_NODE_ID, slot % gigaframe_length);
    //tmp_Event1 = sim_event(1);
    //tmp_Event2 = sim_event(2);
    //printf("tmp_Event1:%d\r\n", tmp_Event1);
    //printf("tmp_Event2:%d \r\n", tmp_Event2);


 		if (slot == 0 ) {
 			if (coordinatorId == TOS_NODE_ID) {
 				call BeaconSend.send(NULL, 0);
 				printf("SENSOR: %u has done network synchronization in SLOT: %u at time: %s:\n", TOS_NODE_ID, slot, sim_time_string());
 			};
 			return;
 		}

  		if ((slot % gigaframe_length) == 0 ) {
 			for (i=0; i<schedule_len; i++){
  				schedule[i][8]=0; //re-enable transmission by set the flag bit to 0, implying this transmission is unfinished and to be conducted.
  				schedule[i][9]=0; //reset "last hop status" to 0 to avoid future confusions, especially in .
  			}
 		}

 		if (slot >= sd+1) {
 			/* //sleep
 			if (slot == sd+1) {
 				call RadioPowerControl.stop();
 				//call Pin.clr();
 			}
 			//wakeup
 			if (slot == bi) {
 				call RadioPowerControl.start();
 				//call Pin.set();
 				//call Leds.led0On();
 			}*/
 			return;
 		}
 		if (slot < cap) {
 		} else {
      if(TOS_NODE_ID != 0)
      {
        set_send (slot % gigaframe_length); //heart beat control
      }


      /*
      if((slot % gigaframe_length) <= schedule_len)
      {
        //printf("id:%u current slot: %u\n", TOS_NODE_ID, slot % gigaframe_length);
        set_send (slot % gigaframe_length); //heart beat control
        if(TOS_NODE_ID==11){
          //printf("Slot checking, this is Sensor: %u and current time slot is: %u\n", TOS_NODE_ID, slot);
        }
      }else
      {

        if((slot % gigaframe_length) == controlschedule_start)
        {
          //printf("controlschedule_start at %u\n",controlschedule_start);
          //
        }else if(((slot % gigaframe_length) > controlschedule_start) && ((slot % gigaframe_length) <= (schedule_len + controlschedule_len)))
        {
          //printf("control Msg broadcast period: %u ~ %u, broadcast node: %u \n",controlschedule_start+1,schedule_len + controlschedule_len, (slot % gigaframe_length) - (controlschedule_start + 1) + (Nodeoffset));
          if((slot % gigaframe_length) - (controlschedule_start + 1) + (Nodeoffset) == TOS_NODE_ID)
          {
            //printf("%u node broadcast at %u\n", TOS_NODE_ID, (slot % gigaframe_length));
            //
          }
        }
      }
      */

 		}
 	}

 	async command error_t Send.send(message_t * msg, uint8_t len) {
 		atomic {
 			if (toSend == NULL) {
 				toSend = msg;
 				toSendLen = len;
 				return SUCCESS;
 			}
 		}
 		return FAIL;
 	}

	async event void SubSend.sendDone(message_t * msg, error_t error) {
		uint32_t slot_at_send_done;
		uint8_t ack_at_send_done;
		slot_at_send_done = call SlotterControl.getSlot() % gigaframe_length;
		ack_at_send_done = call PacketAcknowledgements.wasAcked(msg)?1:0;
		//link failure statistics
		if(ack_at_send_done==0){
			//printf("%u, %u, %u, %u, %u, %u\n", 1, TOS_NODE_ID, call AMPacket.destination(msg), call SlotterControl.getSlot(), call CC2420Config.getChannel(), 0);
		}
		set_send_status(slot_at_send_done, ack_at_send_done);
		//printf("Slot: %u, SENSOR:%u, Sent to: %u with %s @ %s\n", call SlotterControl.getSlot(), TOS_NODE_ID, call AMPacket.destination(msg), call PacketAcknowledgements.wasAcked(msg)? "ACK":"NOACK", sim_time_string());
		if (msg == &packet) {
			if (call AMPacket.type(msg) != SIMPLE_TDMA_SYNC) {
				signal Send.sendDone(msg, error);
			} else {
			}
		}
	}

 	async command error_t Send.cancel(message_t *msg) {
  		atomic {
 			if (toSend == NULL) return SUCCESS;
 			atomic toSend = NULL;
 		}
 		return call SubSend.cancel(msg);
 	}

	/**
	 * Receive
	 */
	async event void SubReceive.receive(message_t *msg, void *payload, uint8_t len) {
		am_addr_t src = call AMPacket.source(msg);
		uint8_t i;
		uint8_t flow_id_rcv;
		char * printfResults;
		set_current_hop_status(call SlotterControl.getSlot() % gigaframe_length, src, TOS_NODE_ID);
		flow_id_rcv=get_flow_id(call SlotterControl.getSlot() % gigaframe_length, src, TOS_NODE_ID);
		if(TOS_NODE_ID==10){
			printf("FLOW:%u RECEIVED: %u->%u, SLOT:%u (time: %s), channel: %u\n", flow_id_rcv, src, TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
			//Flow ID, Delay(Slot when received), sender, receiver, channel, physical time.

			//printf("%u, SLOT: %u, %u, %u, %u, with GETSLOT:%u and absolute TIME:%s\n", flow_id_rcv, call SlotterControl.getSlot() % gigaframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel(), call SlotterControl.getSlot(), sim_time_string());
			printf("%u, SLOT: %u, %u, %u, %u\n", flow_id_rcv, call SlotterControl.getSlot() % gigaframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());
			//call TossimComPrintfWrite.printfWrite(flow_id_rcv, call SlotterControl.getSlot() % gigaframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel()); //writing results to file, differentiated by file name
			//printf("This is Sensor: %u, and we have just called TossimComPrintfWrite.printfWrite, at Slot: %u\n", TOS_NODE_ID, call SlotterControl.getSlot() % gigaframe_length);

			//below is the tcp approach based on a global variable on each sensor, tcp_msg, defined in SimMoteP.nc added by Bo
			call SimMote.setTcpMsg(flow_id_rcv, call SlotterControl.getSlot() % gigaframe_length, src, TOS_NODE_ID, call CC2420Config.getChannel());

		}
    /****** Relay part ************/

    /******************************/

    printf("RECEIVE: %u->%u, SLOT:%u (time: %s), channel: %u\n", src,TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string(), call CC2420Config.getChannel());
		signal Receive.receive(msg, payload, len);
	}

	/**
	 * Frame configuration
	 * These interfaces are provided for external use, which is misleading as these interfaces are already implemented in GenericClotterC and P
	 */
  	command void Frame.setSlotLength(uint32_t slotTimeBms) {
		atomic slotSize = slotTimeBms;
		call FrameConfiguration.setSlotLength(slotSize);
 	}
 	command void Frame.setFrameLength(uint32_t numSlots) {
 		atomic bi = numSlots;
		call FrameConfiguration.setFrameLength(bi + 1);
 	}
 	command uint32_t Frame.getSlotLength() {
 		return slotSize;
 	}
 	command uint32_t Frame.getFrameLength() {
 		return bi + 1;
 	}

	/**
	 * MISC functions
	 */
	async command void *Send.getPayload(message_t * msg, uint8_t len) {
		return call SubSend.getPayload(msg, len);
	}

	async command uint8_t Send.maxPayloadLength() {
		return call SubSend.maxPayloadLength();
	}

	//provide the receive interface
	command void Receive.updateBuffer(message_t * msg) { return call SubReceive.updateBuffer(msg); }

	default async event uint16_t CcaControl.getInitialBackoff[am_id_t id](message_t * msg, uint16_t defaultbackoff) {
		return 0;
	}

	default async event uint16_t CcaControl.getCongestionBackoff[am_id_t id](message_t * msg, uint16_t defaultBackoff) {
		return 0;
	}

	default async event bool CcaControl.getCca[am_id_t id](message_t * msg, bool defaultCca) {
		return FALSE;
	}

    event void CC2420Config.syncDone(error_t error){}
    async event void BeaconSend.sendDone(message_t * msg, error_t error){}

    uint8_t get_last_hop_status(uint8_t flow_id_t, uint8_t access_type_t, uint8_t hop_count_t){
    	uint8_t last_hop_status=0;
    	uint8_t i;
    	for (i=0; i<schedule_len; i++){
    		if(schedule[i][0] <= call SlotterControl.getSlot() % gigaframe_length){
    			if (schedule[i][6]==flow_id_t){//check flow ID
					if(schedule[i][10] == (hop_count_t-1)){//check the previous hop-count
						if(schedule[i][9]==1){
							last_hop_status = schedule[i][9];
							//printf("Sensor:%u, GETTING RECEIVE, Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8], schedule[i][9], schedule[i][10]);
						}
					}
    			}
    		}
		}
		return last_hop_status;
    }//end of get_last_hop_status

    void set_current_hop_status(uint32_t slot_t, uint8_t sender, uint8_t receiver){
    	uint8_t i;
    	for (i=0; i<schedule_len; i++){
    		if(schedule[i][0]==slot_t){// check send-receive pairs 1 slot before/after current slot
    			if(schedule[i][1] == sender){//check sender
					if(schedule[i][2] == receiver){//check receiver
						schedule[i][9]=1;
						//printf("Sensor:%u, SETTING RECEIVE, Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u, [9]%u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8], schedule[i][9], schedule[i][10]);
					}
				}
    		}
		}
    }// end of set_current_hop_status

    uint8_t get_flow_id(uint32_t slot_t, uint8_t sender, uint8_t receiver){
    	uint8_t i;
    	uint8_t flow_id_t=0;
    	for (i=0; i<schedule_len; i++){
    		if(schedule[i][0]==slot_t){// check send-receive pairs 1 slot before/after current slot
    			if(schedule[i][1] == sender){//check sender
					if(schedule[i][2] == receiver){//check receiver
						flow_id_t=schedule[i][6];
					}
				}
    		}
		}
		return flow_id_t;
    } // end of get_flow_id

	void set_send_status(uint32_t slot_at_send_done, uint8_t ack_at_send_done){
   		uint8_t k, i;
   		uint8_t flow_id_at_send_done;
   		uint8_t root_id_at_send_done;
   		uint8_t access_type_at_send_done;

		for (k=0; k<schedule_len; k++){
			if(schedule[k][0] == slot_at_send_done && schedule[k][1] ==TOS_NODE_ID){
				flow_id_at_send_done=schedule[k][6];
				root_id_at_send_done=schedule[k][7];
				access_type_at_send_done=schedule[k][4]; // get the right line of the schedule
			}
		}

		//printf("SENSOR:%u, Slot:%u, i:%u\n", TOS_NODE_ID, slot_at_send_done, i);
		if(access_type_at_send_done == 0 || access_type_at_send_done == 2){ // if this is a dedicated slot
		//if(access_type_at_send_done == 0){ // if this is a dedicated slot
			if (ack_at_send_done==1){
				for (i=0; i<schedule_len; i++){
					if (schedule[i][6]==flow_id_at_send_done){ //check flow id
						if(schedule[i][7] == root_id_at_send_done){//check root
							// if (TOS_NODE_ID == 10 || TOS_NODE_ID == 69 || TOS_NODE_ID == 14 || TOS_NODE_ID == 73){
							// 	printf("$$$SENSOR: %u has successfully sent a packet in SLOT:%u.\n", TOS_NODE_ID, slot_at_send_done);
							// }
							schedule[i][8]=1;
							//printf("***DEDICATED: SENSOR: %u, KILLING POTENTIAL SEND: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
						}
					}
				}
			}
			else{
			}
		}else if(access_type_at_send_done==1){//if this is a shared slot
			//printf("SHARED: SENSOR: %u, DISABLING: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
			if (ack_at_send_done==1){
				//printf("SHARED111: SENSOR: %u, KILLING POTENTIAL SEND: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
			}
			else{
				for (i=0; i<schedule_len; i++){
					if (schedule[i][6]==flow_id_at_send_done){ //check flow id
							schedule[i][8]=1;
					}
				}
				//printf("SHARED222: SENSOR: %u, KILLING POTENTIAL SEND: Slot:%u, %u, %u, %u, %u, %u , %u, %u, %u.\n", TOS_NODE_ID, schedule[i][0], schedule[i][1], schedule[i][2], schedule[i][3], schedule[i][4], schedule[i][5], schedule[i][6], schedule[i][7], schedule[i][8]);
			}
		}
   }// end of set_send_status

   	void set_send (uint32_t slot_t){
		uint8_t i;
		uint32_t slot_norm = slot_t; //Here slot_norm is the real time slot normalized by superframe length
		// bool idleStatus;
		for (i=0; i<schedule_len; i++){
  			if (slot_norm == schedule[i][0]){//check slot
  				if(TOS_NODE_ID == schedule[i][1] || TOS_NODE_ID == schedule[i][2]){//check sender & receiver id
  					if(schedule[i][10]>1){ //check if this is on a multi-hop path
  						if(TOS_NODE_ID == schedule[i][1] && schedule[i][8]==0){//No. 8 in the schedule is Send status in sendDone
  			  				if (get_last_hop_status(schedule[i][6], schedule[i][4], schedule[i][10])){// if above so, check delivery status of last hop
								call CC2420Config.setChannel(schedule[i][3]);
  								call CC2420Config.sync();
  								call AMPacket.setDestination(&packet, schedule[i][2]);
  								call PacketAcknowledgements.requestAck(&packet);

  								call TossimPacketModelCCA.set_cca(schedule[i][4]); //schedule[i][4]: 0, TDMA; 1, CSMA contending; 2, CSMA steal;
	  							call SubSend.send(&packet, sizeof(TestNetworkMsg));

	  							//sequence, sender, receiver, access type, slot, channel
	  							//printf("Node: %u, Link Failure detection.\n");
	  							//printf("%u, %u, %u, %u, %u, %u, %u, %u\n", 0, TOS_NODE_ID, schedule[i][2], schedule[i][4], slot_norm, call CC2420Config.getChannel(), schedule[i][5], schedule[i][6]);

	  							// print out multihop send status
	  							//printf("SENDER, HOP >1: %u->%u, Flow:%u, AccessType:%u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, call AMPacket.destination(&packet), schedule[i][6], schedule[i][4], slot_norm, schedule[i][3], sim_time_string());
  			  				}// end check last hop
  			  			}// end sender check
  			  			if(TOS_NODE_ID == schedule[i][2] && schedule[i][8]==0){
 	 			  				//printf("RECEIVER, HOP >1: %u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, slot_norm, schedule[i][3], sim_time_string());
  			  					call CC2420Config.setChannel(schedule[i][3]);
  								call CC2420Config.sync();
  						}//end receiver check
  					}else{
  						if(TOS_NODE_ID == schedule[i][1] && schedule[i][8]==0){

                //send SendNodeIDMsg to Tossim
                printf("Nodeid:%d,   Send to tossim, SLOT:%d (time:%s)\r\n",TOS_NODE_ID, call SlotterControl.getSlot(), sim_time_string());
                call SimMote.setSendNodeIDMsg(TOS_NODE_ID);

  			  			call CC2420Config.setChannel(schedule[i][3]);
  							call CC2420Config.sync();
  							call AMPacket.setDestination(&packet, schedule[i][2]);
  							call PacketAcknowledgements.requestAck(&packet);
	  						call TossimPacketModelCCA.set_cca(schedule[i][4]); //schedule[i][4]: 0, TDMA; 1, CSMA contending; 2, CSMA steal;
	  						call SubSend.send(&packet, sizeof(TestNetworkMsg));

	  					}
  						if(TOS_NODE_ID == schedule[i][2] && schedule[i][8]==0){
	  						//printf("RECEIVER, HOP =1: %u, slot: %u, channel: %u, time: %s\n", TOS_NODE_ID, slot_norm, schedule[i][3], sim_time_string());
  			  				call CC2420Config.setChannel(schedule[i][3]);
  							call CC2420Config.sync();
  						}
  					}//end else
  				}//end slot check
  			}//end sender || receiver check
  		}//end for
   	}//end set_send


}
