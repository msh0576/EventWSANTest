interface Useful{

  //async command uint8_t* DeadlineList(uint8_t* Pkt_Character);

  //async command uint8_t* TaskSenderReceiver(uint8_t taskid, uint8_t hopcount);

  //async command void MakeRoute(uint8_t transmission_type, uint8_t graph[][7]);

  async command void SetSR(uint8_t schedule[][11],uint8_t transmission_type, uint8_t flowid, uint8_t hopcount, uint32_t Superframe);
}
