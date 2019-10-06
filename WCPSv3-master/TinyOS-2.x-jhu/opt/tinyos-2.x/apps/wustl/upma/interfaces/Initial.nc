
interface Initial {

  async command uint8_t * Broadcast();

  async command uint8_t (* Uplink())[NODE_NUMBER];

  async command uint8_t * Downlink();

  async command uint8_t (* Flow_character())[TASK_SIZE];
}
