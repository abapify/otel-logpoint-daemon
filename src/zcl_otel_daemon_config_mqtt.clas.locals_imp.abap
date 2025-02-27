*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class lcl_noop_mqtt_handler definition.
public section.
interfaces IF_MQTT_EVENT_HANDLER.
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
