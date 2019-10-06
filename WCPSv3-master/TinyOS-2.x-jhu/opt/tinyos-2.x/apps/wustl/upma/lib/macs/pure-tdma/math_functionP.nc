module math_functionP {
  provides{
    interface math_function;
  }
}
implementation {


  async command uint32_t math_function.lcm(uint16_t a, uint16_t b){
    uint32_t lcm;
    uint16_t temp;

    lcm = 0;
    temp = 0;

    if(a > b)
    {
      temp = a;
      a = b;
      b = temp;
    }

    for(lcm = b; ; lcm = lcm + b)
    {
      if(lcm%a == 0)
      {
        return lcm;
      }
    }
    return -1;
  }


  async command uint32_t math_function.gcd(uint16_t a, uint16_t b){
    uint32_t gcd;
    uint16_t temp;

    gcd = 0;
    temp = 0;

    if(a > b)
    {
      temp = a;
      a = b;
      b = temp;
    }

    for(gcd = a; ; gcd--)
    {
      if((a%gcd==0)&&(b%gcd==0))
      {
        return gcd;
      }
    }
    return -1;
  }



}
