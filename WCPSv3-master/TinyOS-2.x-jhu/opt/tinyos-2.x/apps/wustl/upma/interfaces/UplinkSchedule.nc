interface UplinkSchedule{
  //return uplink schedule matrkx [N][N]
  async command uint8_t (*matrix())[11];

}
