*&---------------------------------------------------------------------*
*& Report ZTEST_OTEL_DAEMON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zotel_daemon_rtm_admin.

selection-screen begin of block b02 with frame title text-b02.
  parameters x_create radiobutton group mod default 'X' user-command mod.
  parameters x_ping   radiobutton group mod.
  parameters x_export radiobutton group mod.
  parameters x_status radiobutton group mod.
selection-screen end of block b02.

selection-screen begin of block b01 with frame.
  parameters p_name type if_abap_daemon_types=>ty_abap_daemon_name default 'ZCL_OTEL_DAEMON_RTM' modif id nam.
  parameters p_cls type if_abap_daemon_types=>ty_abap_daemon_class_name default 'ZCL_OTEL_DAEMON_RTM' modif id cls.
  parameters p_did type if_abap_daemon_types=>ty_abap_daemon_daemon_id default 'ZCL_OTEL_DAEMON_RTM' modif id did.
selection-screen end of block b01.

selection-screen begin of block b03 with frame.
  parameters p_dest type RFCDEST modif id des default 'ABAP2OTEL_MQTT'.
selection-screen end of block b03.

class lcl_startup_config definition.
  public section.
    interfaces zif_otel_daemon_config.
    interfaces if_serializable_object.
endclass.

class lcl_app definition.
  public section.
    methods start raising cx_static_check.
    methods at_output.
    methods get_instance_id
      returning value(result) type if_abap_daemon_types=>ty_abap_daemon_instance_id
      raising   cx_abap_daemon_error.
  private section.
    methods ping raising cx_abap_daemon_error cx_ac_message_type_pcp_error.
    methods export raising cx_abap_daemon_error cx_ac_message_type_pcp_error.
endclass.

class lcl_noop_mqtt_handler definition.
public section.
interfaces IF_MQTT_EVENT_HANDLER.
endclass.


initialization.

  data(app) = new lcl_app( ).

start-of-selection.

  try.
      app->start( ).
    catch cx_root into data(lo_cx).
      message lo_cx type 'I' display like 'E'.
  endtry.

at selection-screen output.

  app->at_output( ).

class lcl_app implementation.
  method start.

    case abap_true.

      when x_create.

        data(config) = cl_abap_daemon_startup_manager=>create_for_current_program( ).
        data(daemon_config) = zcl_otel_daemon_config=>set( new lcl_startup_config( ) )  .

        try.

            config->insert_by_trusted_user(
                 i_daemon_id      = p_did                 " Daemon ID
                 i_class_name     = p_cls                 " ABAP Daemon Class Name
                 i_name           = p_name                " ABAP Daemon Name
                 i_user_name      = sy-uname                 " ABAP Daemon User Name
*          i_language       =                  " ABAP Daemon Language Key
              i_parameter      = daemon_config               " ABAP Channels message type Push Channel Protocol (PCP)
*          i_priority       =                  " ABAP Daemon Priority
                 i_topology_type  = if_abap_daemon_startup_config=>startup_topology_type-server                 " ABAP Daemon Topology Type
*          i_topology_value =                  " ABAP Daemon Topology Value
                 i_instances      = 1                 " ABAP Daemon Instances
               ).

          catch cx_abap_daemon_startup_error.

            config->update_by_trusted_user(
            i_daemon_id      = p_did                 " Daemon ID
            i_class_name     = p_cls                 " ABAP Daemon Class Name
            i_name           = p_name                " ABAP Daemon Name
            i_user_name      = sy-uname                 " ABAP Daemon User Name
*          i_language       =                  " ABAP Daemon Language Key
          i_parameter      = daemon_config                " ABAP Channels message type Push Channel Protocol (PCP)
*          i_priority       =                  " ABAP Daemon Priority
            i_topology_type  = if_abap_daemon_startup_config=>startup_topology_type-server                " ABAP Daemon Topology Type
*          i_topology_value =                  " ABAP Daemon Topology Value
            i_instances      = 1                 " ABAP Daemon Instances
            ).
*          catch cx_abap_daemon_startup_error. " ADF: Error handling class for ABAP Daemon startup

        endtry.

        config->execute( ).
*        catch cx_abap_daemon_startup_error. " ADF: Error handling class for ABAP Daemon startup

      when x_status.

        cl_abap_daemon_client_manager=>get_daemon_info(
          exporting
            i_daemon_id  = p_did
            i_class_name = p_cls                 " ABAP Daemon Class Name
          receiving
            r_info_table = data(lt_info)                 " ABAP Daemon information table
        ).

        cl_demo_output=>display_data( lt_info ).

      when x_ping.

        ping( ).

      when x_export.

        export( ).

    endcase.

  endmethod.

  method at_output.

    loop at screen.
      case screen-group1.
        when 'NAM'.
          if not ( x_create eq abap_true ).
            screen-active = 0.
          endif.
        when 'DID'.
          if not ( x_create eq abap_true  or x_status eq abap_true or x_ping eq abap_true or x_export eq abap_true  ).
            screen-active = 0.
          endif.
        when 'CLS'.
          if not ( x_create eq abap_true or x_status eq abap_true or x_ping eq abap_true or x_export eq abap_true  ).
            screen-active = 0.
          endif.
        when 'DES'.
          if not ( x_create eq abap_true ).
            screen-active = 0.
          endif.
      endcase.
      modify screen.
    endloop.

  endmethod.

  method get_instance_id.

    cl_abap_daemon_client_manager=>get_daemon_info(
          exporting
            i_daemon_id  = p_did
            i_class_name = p_cls                 " ABAP Daemon Class Name
          receiving
            r_info_table = data(lt_info)                 " ABAP Daemon information table
        ).

    check lt_info is not initial.
    result = lt_info[ 1 ]-instance_id.
  endmethod.

  method ping.
    data(lo_handle) = cl_abap_daemon_client_manager=>attach(  get_instance_id( ) ).
    data(lo_pcp_message) = cl_ac_message_type_pcp=>create( ).

    lo_pcp_message->set_field(
      i_name  = 'command'
      i_value = 'ping'
    ).

    lo_handle->send( lo_pcp_message ).
  endmethod.

  method export.

    data(lo_handle) = cl_abap_daemon_client_manager=>attach(  get_instance_id( ) ).
    data(lo_pcp_message) = cl_ac_message_type_pcp=>create( ).

    lo_pcp_message->set_field(
      i_name  = 'command'
      i_value = 'export'
    ).

    lo_handle->send( lo_pcp_message ).
  endmethod.
endclass.

class lcl_startup_config implementation.
  method zif_otel_daemon_config~publisher.

    data(client) =
    cl_mqtt_client_manager=>create_by_destination(
      exporting
        i_destination      = conv #( p_dest )
        i_event_handler    = new lcl_noop_mqtt_handler(  )
    ).

    data(lo_options) = cl_mqtt_connect_options=>create( ).
    lo_options->set_client_id( |{ sy-sysid }/{ sy-mandt }| ).

    client->connect(
      i_mqtt_options =  lo_options                " MQTT connect options
      i_apc_options  = value #(
      timeout = 1 )                 " Structure APC connect options
    ).

    result = new ZCL_OTEL_PUBLISHER_MQTT(
      topic_name = |abap2otel/traces/{ sy-sysid }/{ sy-mandt }|
      client = client
    ).

  endmethod.

endclass.

CLASS lcl_noop_mqtt_handler IMPLEMENTATION.

  METHOD if_mqtt_event_handler~on_connect.

  ENDMETHOD.

  METHOD if_mqtt_event_handler~on_disconnect.

  ENDMETHOD.

  METHOD if_mqtt_event_handler~on_message.

  ENDMETHOD.

  METHOD if_mqtt_event_handler~on_publish.

  ENDMETHOD.

  METHOD if_mqtt_event_handler~on_subscribe.

  ENDMETHOD.

  METHOD if_mqtt_event_handler~on_unsubscribe.

  ENDMETHOD.

ENDCLASS.
