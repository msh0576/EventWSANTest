//#define MAX_SHCEDULE_SIZE 100
//#define NODE_NUMBER 5
//#define TASK_NUMBER 2
//#define TASK_SIZE 5   //[0]:Flow root, [1]:Flow id, [2]:Pkt period, [3]: Pkt Deadline [4]:Destination

enum {
  MAX_SHCEDULE_SIZE = 100,   //Final schedule max row size
  NODE_NUMBER = 5,   //Total network node
  TASK_NUMBER = 2,   //Network flow (Task) number
  TASK_SIZE = 5,   //[0]:Flow root, [1]:Flow id, [2]:Pkt period, [3]: Pkt Deadline [4]:Destination
  NODE_OFFSET = 10
};
