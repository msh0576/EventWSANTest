interface DynamicSchedule{

  async command void Initial(uint8_t Task_character[][4], uint32_t Superframe);

  async command void Scheduler(uint8_t schedule[][11], uint32_t Superframe);

  async command uint32_t MakeSF(uint8_t Task_character[][4], uint8_t TaskNumber);
}
