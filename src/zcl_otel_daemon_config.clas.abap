class zcl_otel_daemon_config definition
  public
  abstract
  final
  create public .

  public section.

    types config_type type ref to zif_otel_daemon_config.
    types message_type type ref to if_ac_message_type_pcp.

    class-methods set
      importing
        !config       type config_type
      returning
        value(result) type message_type
        raising cx_ac_message_type_pcp_error.


    class-methods get
      importing
        !message      type message_type
      returning
        value(result) type config_type
        raising cx_ac_message_type_pcp_error.

  protected section.
  private section.
ENDCLASS.



CLASS ZCL_OTEL_DAEMON_CONFIG IMPLEMENTATION.


  method get.

    check message is bound.

    data(binary) = message->get_binary( ).

    call transformation id
      source xml binary
      result config = result.

  endmethod.


  method set.

    check config is bound.

    call transformation id
      source config = config
      result xml data(binary).

    result = cl_ac_message_type_pcp=>create( ).
    result->set_binary( binary ).

  endmethod.
ENDCLASS.
