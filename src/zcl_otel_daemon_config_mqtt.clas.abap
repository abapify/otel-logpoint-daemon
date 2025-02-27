class ZCL_OTEL_DAEMON_CONFIG_MQTT definition
  public
  final
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .
  interfaces ZIF_OTEL_DAEMON_CONFIG .

  methods constructor
    importing RFC_DESTINATION type csequence.

protected section.
private section.

  data RFC_DESTINATION type RFCDEST .
ENDCLASS.



CLASS ZCL_OTEL_DAEMON_CONFIG_MQTT IMPLEMENTATION.


  method constructor.
    me->rfc_destination = rfc_destination.
  endmethod.


  method ZIF_OTEL_DAEMON_CONFIG~PUBLISHER.

     data(client) =
    cl_mqtt_client_manager=>create_by_destination(
      exporting
        i_destination      = conv #( me->rfc_destination )
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
ENDCLASS.
