configuration InitialC {
  provides{
    interface Initial;
  }
}
implementation {
  components InitialP;

  Initial = InitialP.Initial;

}
