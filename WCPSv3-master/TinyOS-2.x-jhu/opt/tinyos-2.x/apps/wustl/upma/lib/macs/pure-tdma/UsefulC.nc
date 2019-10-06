configuration UsefulC {
  provides{
    interface Useful;
  }
}
implementation {

  components UsefulP;

  Useful = UsefulP.Useful;

}
