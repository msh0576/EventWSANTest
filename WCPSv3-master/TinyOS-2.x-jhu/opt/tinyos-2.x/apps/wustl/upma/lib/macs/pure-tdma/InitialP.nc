
module InitialP {

  provides{
    interface Initial;

  }

}
implementation {


  uint8_t UplinkRouting[NODE_NUMBER][NODE_NUMBER] = {
  {0, 0, 0, 0},
  {1, 0, 0, 0},
  {1, 0, 0, 0},
  {0, 0, 0, 0}
  };

  //[0]:Flow root, [1]:Flow id, [2]:Pkt period, [3]: Pkt Deadline [4]:Destination
  uint8_t flow_character[TASK_NUMBER][TASK_SIZE] = {
  {1, 1, 10, 7, 0},
  {2, 2, 10, 9, 0}
  };

  uint8_t DownlinkRouting[NODE_NUMBER] = {0, 7, 8};


  async command uint8_t * Initial.Broadcast()
  {

  }

  async command uint8_t (* Initial.Uplink())[NODE_NUMBER]
  {
    return UplinkRouting;
  }

  async command uint8_t * Initial.Downlink()
  {

    return DownlinkRouting;
  }

  async command uint8_t (* Initial.Flow_character())[TASK_SIZE]
  {
    return flow_character;
  }

}
