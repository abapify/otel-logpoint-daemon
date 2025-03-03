class zcl_otel_daemon_rtm definition
  public
  inheriting from cl_abap_daemon_ext_base
  final
  create public .

  public section.

    interfaces if_abap_timer_handler .

    methods constructor .

    methods if_abap_daemon_extension~on_accept
        redefinition .
    methods if_abap_daemon_extension~on_before_restart_by_system
        redefinition .
    methods if_abap_daemon_extension~on_error
        redefinition .
    methods if_abap_daemon_extension~on_message
        redefinition .
    methods if_abap_daemon_extension~on_restart
        redefinition .
    methods if_abap_daemon_extension~on_server_shutdown
        redefinition .
    methods if_abap_daemon_extension~on_start
        redefinition .
    methods if_abap_daemon_extension~on_stop
        redefinition .
    methods if_abap_daemon_extension~on_system_shutdown
        redefinition .
  protected section.
private section.

  "data CONFIG type ref to ZIF_OTEL_DAEMON_CONFIG .
  data CONTEXT type ref to IF_ABAP_DAEMON_CONTEXT .


  methods EXPORT
    importing config type ref to zif_otel_daemon_config
    raising
      CX_STATIC_CHECK .

  methods SET_TIMER
    importing
      !CONTEXT type ref to IF_ABAP_DAEMON_CONTEXT
    raising
      CX_ABAP_TIMER_ERROR .
ENDCLASS.



CLASS ZCL_OTEL_DAEMON_RTM IMPLEMENTATION.


  method if_abap_daemon_extension~on_accept.

    " always accept
    e_setup_mode = co_setup_mode-accept.

    try.

        zcl_otel_daemon_config=>get( i_context_base->get_start_parameter(  ) ).

      catch cx_root.

        e_setup_mode = co_setup_mode-reject.

    endtry.

  endmethod.


  method if_abap_daemon_extension~on_before_restart_by_system.

  endmethod.


  method if_abap_daemon_extension~on_error.

    try.
        set_timer( i_context ).
      catch cx_abap_timer_error.
    endtry.

  endmethod.


  method if_abap_daemon_extension~on_message.

    try.
        case i_message->get_field( 'command' ).
          when 'export'.
            export( zcl_otel_daemon_config=>get( i_context->get_start_parameter(  ) ) ).
        endcase.
      catch cx_static_check into data(lo_cx).
        "handle exception
    endtry.

  endmethod.


  method if_abap_daemon_extension~on_restart.


    try.
        set_timer( i_context ).
      catch cx_abap_timer_error.
      catch cx_abap_daemon_error.
      catch cx_ac_message_type_pcp_error.
    endtry.


  endmethod.


  method if_abap_daemon_extension~on_server_shutdown.

  endmethod.


  method if_abap_daemon_extension~on_start.

    try.
        set_timer( i_context  ).
      catch cx_abap_timer_error.
      catch cx_abap_daemon_error.
      catch cx_ac_message_type_pcp_error.
    endtry.

  endmethod.


  method if_abap_daemon_extension~on_stop.


    try.
        set_timer( i_context  ).
      catch cx_abap_timer_error.
      catch cx_abap_daemon_error.
      catch cx_ac_message_type_pcp_error.
    endtry.


  endmethod.


  method if_abap_daemon_extension~on_system_shutdown.

    try.
        export( zcl_otel_daemon_config=>get( i_context->get_start_parameter(  ) ) ).
      catch cx_static_check.
    endtry.

  endmethod.


  method export.

    check config is bound.

    data(publisher) = config->publisher( ).

    data(entry_handler) = new zcl_otel_rtm_handler( stream = publisher ).

    zcl_rtm_iterator=>start(
       entry_handler            = entry_handler
       test_range               = value #( ( |IEQZOTEL_MSG| ) )
       local_server_only = abap_true
       flush_to_db              = abap_true
       delete_processed_from_db = abap_true
     ).
*    catch cx_rtm_persistence.

    " here we don't need to keep connection
    publisher->stop( ).

  endmethod.


  method set_timer.

    me->context = context.

    " every 30 seconds
    cl_abap_timer_manager=>get_timer_manager( )->start_timer(
      i_timer_handler = me                 " ABAP Timer handler
      i_timeout       = 30000                 " Timeout in milliseconds
    ).

  endmethod.


  method if_abap_timer_handler~on_timeout.

    try.

        me->export( zcl_otel_daemon_config=>get( me->context->get_start_parameter(  ) ) ).
        set_timer( me->context ).

      catch cx_static_check into data(lo_cx).

        message lo_cx type 'E'.

    endtry.

  endmethod.


  method constructor.

    super->constructor( ).

  endmethod.
ENDCLASS.
