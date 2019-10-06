/*
 * "Copyright (c) 2007 Washington University in St. Louis.
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL WASHINGTON UNIVERSITY IN ST. LOUIS BE LIABLE TO ANY PARTY
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
 * OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WASHINGTON
 * UNIVERSITY IN ST. LOUIS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * WASHINGTON UNIVERSITY IN ST. LOUIS SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND WASHINGTON UNIVERSITY IN ST. LOUIS HAS NO
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS."
 */

/**
 *
 * @author Octav Chipara
 * @version $Revision: 1.3 $
 * @date $Date: 2011/12/21 17:56:26 $
 */

#include "SenderDispatcher.h"

configuration PureTDMASchedulerC {
	provides {
		interface Init;
		interface AsyncSend as Send;
		interface AsyncReceive as Receive;
		interface SplitControl;
		interface CcaControl[am_id_t amId];
		interface FrameConfiguration;
	}

	uses {
		interface AsyncReceive as SubReceive;
		interface AsyncSend as SubSend;
		interface RadioPowerControl;
		interface AMPacket;
		interface Resend;
		interface PacketAcknowledgements;
		interface CcaControl as SubCcaControl[am_id_t];
		interface ChannelMonitor;
	}
}
implementation {
	components MainC;
	components PureTDMASchedulerP;
	components TDMASlotSenderC;

	components GenericSlotterC;
	components LedsC;
	components SenderDispatcherC;
	components DummyChannelMonitorC;
	components BeaconSlotC;
	components new Alarm32khz32C();

	components ActiveMessageC; //added by bo, for packet acknowledgement
	components CC2420ControlC; //added by bo, for batch schedule/channel switching test
	components TossimPacketModelC; //added by bo, to pass enabling bit of CCA

	components TossimComPrintfC; //added by bo, to do file writing

	components SimMoteP; //added by bo, implement the component that has set/get tcp msg methods

	//provides
	Init = PureTDMASchedulerP.Init;

	SplitControl = PureTDMASchedulerP.SplitControl;
	Send = PureTDMASchedulerP.Send;
	Receive = PureTDMASchedulerP.Receive;
	FrameConfiguration = PureTDMASchedulerP.Frame;
	//wire-in SchedulerP
	MainC.SoftwareInit -> PureTDMASchedulerP;

	PureTDMASchedulerP.GenericSlotter -> GenericSlotterC.AsyncStdControl;
	PureTDMASchedulerP.Slotter -> GenericSlotterC.Slotter;
	PureTDMASchedulerP.SlotterControl ->GenericSlotterC.SlotterControl;
	PureTDMASchedulerP.RadioPowerControl = RadioPowerControl;
	PureTDMASchedulerP.FrameConfiguration -> GenericSlotterC.FrameConfiguration;
	PureTDMASchedulerP.Resend = Resend;

	PureTDMASchedulerP.PacketAcknowledgements=PacketAcknowledgements;
	PureTDMASchedulerP.PacketAcknowledgements->ActiveMessageC;
	//PureTDMASchedulerP.PacketAcknowledgements->TossimPacketModelC.PacketAcknowledgements;

	PureTDMASchedulerP.AMPacket = AMPacket;//AMPacket to extract source/receiver info
	PureTDMASchedulerP.Leds -> LedsC;

	PureTDMASchedulerP.CcaControl = CcaControl;
	PureTDMASchedulerP.CC2420Config -> CC2420ControlC;

	SenderDispatcherC.SubSend = SubSend;
	SenderDispatcherC.SubCcaControl = SubCcaControl;

	TDMASlotSenderC.SubSend -> SenderDispatcherC.Send[TDMA_SLOT];
	TDMASlotSenderC.SubCcaControl -> SenderDispatcherC.SlotsCcaControl[TDMA_SLOT];
	TDMASlotSenderC.AMPacket = AMPacket;

	PureTDMASchedulerP.SubSend -> TDMASlotSenderC.Send;
	PureTDMASchedulerP.BeaconSend -> BeaconSlotC.Send;

	BeaconSlotC.SubReceive = SubReceive;
	PureTDMASchedulerP.SubReceive -> BeaconSlotC.Receive;

	//BeaconSlotC.ChannelMonitor = ChannelMonitor;
	BeaconSlotC.AMPacket = AMPacket;
	BeaconSlotC.SubCcaControl -> SenderDispatcherC.SlotsCcaControl[BEACON_SLOT];
	BeaconSlotC.SubSend -> SenderDispatcherC.Send[BEACON_SLOT];
	BeaconSlotC.SlotterControl ->GenericSlotterC.SlotterControl;
	BeaconSlotC.SyncAlarm -> Alarm32khz32C;
	DummyChannelMonitorC.ChannelMonitor = ChannelMonitor;

	//components HplMsp430GeneralIOC;
	//PureTDMASchedulerP.Pin -> HplMsp430GeneralIOC.Port26;
	PureTDMASchedulerP.TossimPacketModelCCA->TossimPacketModelC.TossimPacketModelCCA;

	PureTDMASchedulerP.TossimComPrintfWrite->TossimComPrintfC.TossimComPrintfWrite;

	//Added by Bo for tcp msg buffer set/get;
	PureTDMASchedulerP.SimMote -> SimMoteP.SimMote;



  //Test
  components IntegrateScheduleC;
  PureTDMASchedulerP.IntegrateSchedule -> IntegrateScheduleC;
}
