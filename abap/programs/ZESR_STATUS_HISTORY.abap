*&---------------------------------------------------------------------*
*& Report ZESR_STATUS_HISTORY
*&---------------------------------------------------------------------*
*& ESR REQUEST - STATUS HISTORY MONITOR
*&---------------------------------------------------------------------*
REPORT zesr_status_history.

*---------------------------------------------------------------------*
* 1. Selection Screen
*---------------------------------------------------------------------*

PARAMETERS:

  p_reqid TYPE zesr_de_reqid OBLIGATORY.

*---------------------------------------------------------------------*
* 2. ALV Output Structure
*
* Using character fields for display avoids the type-conversion
* problems encountered in the request ALV.
*---------------------------------------------------------------------*

TYPES: BEGIN OF ty_status,

         request_id   TYPE char20,
         status_seq   TYPE char20,
         status       TYPE char20,
         status_date  TYPE char20,
         changed_by   TYPE char30,
         comments     TYPE char100,
         status_text  TYPE char30,

       END OF ty_status.

*---------------------------------------------------------------------*
* 3. Global Internal Table
*---------------------------------------------------------------------*

DATA gt_status TYPE STANDARD TABLE OF ty_status
               WITH EMPTY KEY.

*---------------------------------------------------------------------*
* 4. Event Handler Class - Definition
*---------------------------------------------------------------------*

CLASS lcl_status_events DEFINITION.

  PUBLIC SECTION.

    METHODS on_double_click
      FOR EVENT double_click OF cl_salv_events_table
      IMPORTING
        row
        column.

ENDCLASS.

*---------------------------------------------------------------------*
* 5. Event Handler Class - Implementation
*---------------------------------------------------------------------*

CLASS lcl_status_events IMPLEMENTATION.

  METHOD on_double_click.

    DATA:
      ls_status  TYPE ty_status,
      lv_message TYPE string.

*---------------------------------------------------------------------*
* Read selected row
*---------------------------------------------------------------------*

    READ TABLE gt_status
      INDEX row
      INTO ls_status.

    IF sy-subrc <> 0.

      MESSAGE 'Unable to read selected status record.'
        TYPE 'I'.

      RETURN.

    ENDIF.

*---------------------------------------------------------------------*
* Double-click validation
*---------------------------------------------------------------------*

    IF column <> 'STATUS_TEXT'.

      MESSAGE 'Please double-click the Status Text.'
        TYPE 'I'.

      RETURN.

    ENDIF.

*---------------------------------------------------------------------*
* Prepare message
*---------------------------------------------------------------------*

    lv_message =
      |Request: { ls_status-request_id } | &&
      |Sequence: { ls_status-status_seq } | &&
      |Status: { ls_status-status_text } | &&
      |Date: { ls_status-status_date } | &&
      |Changed By: { ls_status-changed_by } | &&
      |Comments: { ls_status-comments }|.

*---------------------------------------------------------------------*
* Display message
*---------------------------------------------------------------------*

    MESSAGE lv_message TYPE 'I'.

  ENDMETHOD.

ENDCLASS.

*---------------------------------------------------------------------*
* 6. Start of Selection
*---------------------------------------------------------------------*

START-OF-SELECTION.

*---------------------------------------------------------------------*
* 7. Read Status History from CDS
*
* Important:
* Do NOT declare an internal table directly as ZESR_C_STATUS.
* We explicitly convert every field into our ALV structure.
*---------------------------------------------------------------------*

  SELECT
    RequestId,
    StatusSequence,
    Status,
    StatusDate,
    ChangedBy,
    Comments,
    StatusText

    FROM zesr_c_status

    WHERE RequestId = @p_reqid

    ORDER BY StatusSequence

    INTO TABLE @DATA(lt_db).

*---------------------------------------------------------------------*
* 8. No History Check
*---------------------------------------------------------------------*

  IF lt_db IS INITIAL.

    MESSAGE
      |No status history found for request { p_reqid }.|
      TYPE 'I'.

    RETURN.

  ENDIF.

*---------------------------------------------------------------------*
* 9. Convert CDS Data to ALV Structure
*---------------------------------------------------------------------*

  LOOP AT lt_db ASSIGNING FIELD-SYMBOL(<ls_db>).

    DATA(ls_status) = VALUE ty_status( ).

*---------------------------------------------------------------------*
* Request ID
*---------------------------------------------------------------------*

    ls_status-request_id =
      |{ <ls_db>-RequestId }|.

*---------------------------------------------------------------------*
* Status Sequence
*---------------------------------------------------------------------*

    ls_status-status_seq =
      |{ <ls_db>-StatusSequence }|.

*---------------------------------------------------------------------*
* Status Code
*---------------------------------------------------------------------*

    ls_status-status =
      |{ <ls_db>-Status }|.

*---------------------------------------------------------------------*
* Status Date
*---------------------------------------------------------------------*

    ls_status-status_date =
      |{ <ls_db>-StatusDate }|.

*---------------------------------------------------------------------*
* Changed By
*---------------------------------------------------------------------*

    ls_status-changed_by =
      |{ <ls_db>-ChangedBy }|.

*---------------------------------------------------------------------*
* Comments
*---------------------------------------------------------------------*

    ls_status-comments =
      |{ <ls_db>-Comments }|.

*---------------------------------------------------------------------*
* Status Text
*---------------------------------------------------------------------*

    ls_status-status_text =
      |{ <ls_db>-StatusText }|.

*---------------------------------------------------------------------*
* Append
*---------------------------------------------------------------------*

    APPEND ls_status TO gt_status.

  ENDLOOP.

*---------------------------------------------------------------------*
* 10. Create SALV ALV
*---------------------------------------------------------------------*

  TRY.

      cl_salv_table=>factory(

        IMPORTING
          r_salv_table = DATA(lo_alv)

        CHANGING
          t_table = gt_status ).

*---------------------------------------------------------------------*
* 11. Enable Standard ALV Functions
*---------------------------------------------------------------------*

      lo_alv->get_functions( )->set_all( abap_true ).

*---------------------------------------------------------------------*
* 12. Register Double-Click Event
*---------------------------------------------------------------------*

      DATA(lo_events) = lo_alv->get_event( ).

      DATA(lo_handler) = NEW lcl_status_events( ).

      SET HANDLER lo_handler->on_double_click
        FOR lo_events.

*---------------------------------------------------------------------*
* 13. Optimize Columns
*---------------------------------------------------------------------*

      DATA(lo_columns) = lo_alv->get_columns( ).

      lo_columns->set_optimize( abap_true ).

*---------------------------------------------------------------------*
* 14. ALV Title
*---------------------------------------------------------------------*

      lo_alv->get_display_settings( )->set_list_header(

        |ESR STATUS HISTORY - REQUEST { p_reqid }| ).

*---------------------------------------------------------------------*
* 15. Request ID Column
*---------------------------------------------------------------------*

      DATA(lo_column) =
        lo_columns->get_column( 'REQUEST_ID' ).

      lo_column->set_short_text( 'Request' ).

      lo_column->set_medium_text( 'Request ID' ).

      lo_column->set_long_text( 'ESR Request ID' ).

*---------------------------------------------------------------------*
* 16. Status Sequence Column
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'STATUS_SEQ' ).

      lo_column->set_short_text( 'Seq.' ).

      lo_column->set_medium_text( 'Status Sequence' ).

      lo_column->set_long_text( 'Status Sequence Number' ).

*---------------------------------------------------------------------*
* 17. Status Code Column
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'STATUS' ).

      lo_column->set_short_text( 'Code' ).

      lo_column->set_medium_text( 'Status Code' ).

      lo_column->set_long_text( 'Status Code' ).

*---------------------------------------------------------------------*
* 18. Status Text Column
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'STATUS_TEXT' ).

      lo_column->set_short_text( 'Status' ).

      lo_column->set_medium_text( 'Status' ).

      lo_column->set_long_text( 'Request Status' ).

*---------------------------------------------------------------------*
* 19. Status Date Column
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'STATUS_DATE' ).

      lo_column->set_short_text( 'Date' ).

      lo_column->set_medium_text( 'Status Date' ).

      lo_column->set_long_text( 'Status Change Date' ).

*---------------------------------------------------------------------*
* 20. Changed By Column
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'CHANGED_BY' ).

      lo_column->set_short_text( 'Changed By' ).

      lo_column->set_medium_text( 'Changed By' ).

      lo_column->set_long_text( 'Status Changed By' ).

*---------------------------------------------------------------------*
* 21. Comments Column
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'COMMENTS' ).

      lo_column->set_short_text( 'Comments' ).

      lo_column->set_medium_text( 'Comments' ).

      lo_column->set_long_text( 'Status Comments' ).

*---------------------------------------------------------------------*
* 22. Display ALV
*---------------------------------------------------------------------*

      lo_alv->display( ).

*---------------------------------------------------------------------*
* 23. Exception Handling
*---------------------------------------------------------------------*

    CATCH cx_salv_msg INTO DATA(lx_error).

      MESSAGE
        lx_error->get_text( )
        TYPE 'E'.

  ENDTRY.