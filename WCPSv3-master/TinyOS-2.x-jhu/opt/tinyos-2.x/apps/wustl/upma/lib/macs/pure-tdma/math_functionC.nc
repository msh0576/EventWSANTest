configuration math_functionC {
  provides{
    interface math_function;
  }
}
implementation {

  components math_functionP;

  math_function = math_functionP.math_function;

}
