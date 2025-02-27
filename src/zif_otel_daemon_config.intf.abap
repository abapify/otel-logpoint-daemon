interface ZIF_OTEL_DAEMON_CONFIG
  public .

  interfaces if_serializable_object.


  methods PUBLISHER
    returning
      value(RESULT) type ref to ZIF_OTEL_PUBLISHER
    raising
      CX_STATIC_CHECK .
endinterface.
