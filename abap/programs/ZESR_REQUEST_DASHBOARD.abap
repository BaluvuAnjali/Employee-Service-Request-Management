
*&---------------------------------------------------------------------*
*& Report ZESR_REQUEST_DASHBOARD
*&---------------------------------------------------------------------*
*& ESR REQUEST MANAGEMENT DASHBOARD
*&---------------------------------------------------------------------*
REPORT zesr_request_dashboard.

*---------------------------------------------------------------------*
* 1. ALV OUTPUT STRUCTURE
*---------------------------------------------------------------------*

TYPES: BEGIN OF ty_request,

         requestid    TYPE char20,
         employeeid   TYPE char20,
         requesttype  TYPE char20,
         priority     TYPE char20,
         status       TYPE char20,
         statustext   TYPE char40,
         materialid   TYPE char40,
         quantity     TYPE char20,
         reason       TYPE char100,
         requestdate  TYPE char20,
         requireddate TYPE char20,
         latest_date  TYPE char20,
         changed_by   TYPE char40,
         comments     TYPE char100,

       END OF ty_request.

*---------------------------------------------------------------------*
* 2. HISTORY STRUCTURE
*---------------------------------------------------------------------*

TYPES: BEGIN OF ty_history,

         requestid    TYPE char20,
         statusseq    TYPE char20,
         status       TYPE char20,
         statusdate   TYPE char20,
         changedby    TYPE char40,
         comments     TYPE char100,
         statustext   TYPE char40,

       END OF ty_history.

*---------------------------------------------------------------------*
* 3. INTERNAL TABLES
*---------------------------------------------------------------------*

DATA:

  gt_requests TYPE STANDARD TABLE OF ty_request
              WITH EMPTY KEY,

  gt_history TYPE STANDARD TABLE OF ty_history
             WITH EMPTY KEY.

*---------------------------------------------------------------------*
* 4. EVENT HANDLER DEFINITION
*---------------------------------------------------------------------*

CLASS lcl_dashboard_events DEFINITION.

  PUBLIC SECTION.

    METHODS on_double_click

      FOR EVENT double_click OF cl_salv_events_table

      IMPORTING
        row
        column.

ENDCLASS.

*---------------------------------------------------------------------*
* 5. EVENT HANDLER IMPLEMENTATION
*---------------------------------------------------------------------*

CLASS lcl_dashboard_events IMPLEMENTATION.

  METHOD on_double_click.

    DATA:

      ls_request TYPE ty_request,
      lv_message TYPE string.

*---------------------------------------------------------------------*
* Read selected row
*---------------------------------------------------------------------*

    READ TABLE gt_requests
      INDEX row
      INTO ls_request.

    IF sy-subrc <> 0.

      MESSAGE
        'Unable to read selected request.'
        TYPE 'I'.

      RETURN.

    ENDIF.

*---------------------------------------------------------------------*
* Only Request ID
*---------------------------------------------------------------------*

    IF column <> 'REQUESTID'.

      MESSAGE
        'Please double-click the Request ID.'
        TYPE 'I'.

      RETURN.

    ENDIF.

*---------------------------------------------------------------------*
* Prepare details
*---------------------------------------------------------------------*

    lv_message =
      |Request ID: { ls_request-requestid } | &&
      |Employee: { ls_request-employeeid } | &&
      |Type: { ls_request-requesttype } | &&
      |Priority: { ls_request-priority } | &&
      |Status: { ls_request-statustext } | &&
      |Material: { ls_request-materialid } | &&
      |Quantity: { ls_request-quantity } | &&
      |Reason: { ls_request-reason } | &&
      |Required Date: { ls_request-requireddate } | &&
      |Changed By: { ls_request-changed_by }|.

*---------------------------------------------------------------------*
* Display
*---------------------------------------------------------------------*

    MESSAGE lv_message TYPE 'I'.

  ENDMETHOD.

ENDCLASS.

*---------------------------------------------------------------------*
* 6. SELECTION SCREEN
*---------------------------------------------------------------------*

PARAMETERS:

  p_emp TYPE zesr_de_emp,

  p_status TYPE zesr_de_status
           AS LISTBOX VISIBLE LENGTH 20.

*---------------------------------------------------------------------*
* 7. DEFAULT STATUS
*---------------------------------------------------------------------*

INITIALIZATION.

  p_status = 'S'.

*---------------------------------------------------------------------*
* 8. STATUS DROPDOWN
*---------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.

  DATA:

    lt_status TYPE vrm_values,
    ls_status TYPE vrm_value.

  CLEAR lt_status.

*---------------------------------------------------------------------*
* All
*---------------------------------------------------------------------*

  CLEAR ls_status.

  ls_status-key  = ''.
  ls_status-text = 'All Statuses'.

  APPEND ls_status TO lt_status.

*---------------------------------------------------------------------*
* Submitted
*---------------------------------------------------------------------*

  CLEAR ls_status.

  ls_status-key  = 'S'.
  ls_status-text = 'Submitted'.

  APPEND ls_status TO lt_status.

*---------------------------------------------------------------------*
* Validated
*---------------------------------------------------------------------*

  CLEAR ls_status.

  ls_status-key  = 'V'.
  ls_status-text = 'Validated'.

  APPEND ls_status TO lt_status.

*---------------------------------------------------------------------*
* Processing
*---------------------------------------------------------------------*

  CLEAR ls_status.

  ls_status-key  = 'P'.
  ls_status-text = 'Processing'.

  APPEND ls_status TO lt_status.

*---------------------------------------------------------------------*
* Fulfilled
*---------------------------------------------------------------------*

  CLEAR ls_status.

  ls_status-key  = 'F'.
  ls_status-text = 'Fulfilled'.

  APPEND ls_status TO lt_status.

*---------------------------------------------------------------------*
* Set Dropdown
*---------------------------------------------------------------------*

  CALL FUNCTION 'VRM_SET_VALUES'

    EXPORTING

      id     = 'P_STATUS'
      values = lt_status.

*---------------------------------------------------------------------*
* 9. START OF SELECTION
*---------------------------------------------------------------------*

START-OF-SELECTION.

*---------------------------------------------------------------------*
* 10. READ REQUEST CDS
*---------------------------------------------------------------------*

  SELECT FROM zesr_c_request

    FIELDS

      RequestId,
      EmployeeId,
      RequestType,
      Priority,
      Status,
      StatusText,
      MaterialId,
      Quantity,
      Reason,
      RequestDate,
      RequiredDate

    WHERE

      ( EmployeeId = @p_emp
        OR @p_emp IS INITIAL )

      AND

      ( Status = @p_status
        OR @p_status IS INITIAL )

    INTO TABLE @DATA(lt_raw).

*---------------------------------------------------------------------*
* 11. NO DATA
*---------------------------------------------------------------------*

  IF lt_raw IS INITIAL.

    MESSAGE
      'No ESR requests found.'
      TYPE 'I'.

    RETURN.

  ENDIF.

*---------------------------------------------------------------------*
* 12. BUILD REQUEST DASHBOARD
*---------------------------------------------------------------------*

  LOOP AT lt_raw ASSIGNING FIELD-SYMBOL(<ls_raw>).

    DATA:

      lv_requestid  TYPE char20,
      lv_employeeid TYPE char20,
      lv_type       TYPE char20,
      lv_priority   TYPE char20,
      lv_status     TYPE char20,
      lv_statustext TYPE char40,
      lv_material   TYPE char40,
      lv_quantity   TYPE char20,
      lv_reason     TYPE char100,
      lv_reqdate    TYPE char20,
      lv_reqdate2   TYPE char20.

*---------------------------------------------------------------------*
* Convert request fields
*---------------------------------------------------------------------*

    CLEAR:

      lv_requestid,
      lv_employeeid,
      lv_type,
      lv_priority,
      lv_status,
      lv_statustext,
      lv_material,
      lv_quantity,
      lv_reason,
      lv_reqdate,
      lv_reqdate2.

    lv_requestid  = |{ <ls_raw>-RequestId }|.
    lv_employeeid = |{ <ls_raw>-EmployeeId }|.
    lv_type       = |{ <ls_raw>-RequestType }|.
    lv_priority   = |{ <ls_raw>-Priority }|.
    lv_status     = |{ <ls_raw>-Status }|.
    lv_statustext = |{ <ls_raw>-StatusText }|.
    lv_material   = |{ <ls_raw>-MaterialId }|.
    lv_quantity   = |{ <ls_raw>-Quantity }|.
    lv_reason     = |{ <ls_raw>-Reason }|.
    lv_reqdate    = |{ <ls_raw>-RequestDate }|.
    lv_reqdate2   = |{ <ls_raw>-RequiredDate }|.

*---------------------------------------------------------------------*
* Clear history
*---------------------------------------------------------------------*

    CLEAR gt_history.

*---------------------------------------------------------------------*
* 13. READ STATUS CDS
*---------------------------------------------------------------------*

    SELECT FROM zesr_c_status

      FIELDS

        RequestId,
        StatusSequence,
        Status,
        StatusDate,
        ChangedBy,
        Comments,
        StatusText

      WHERE RequestId = @<ls_raw>-RequestId

      INTO TABLE @DATA(lt_history_raw).

*---------------------------------------------------------------------*
* 14. Convert history into our own structure
*---------------------------------------------------------------------*

    LOOP AT lt_history_raw
      ASSIGNING FIELD-SYMBOL(<ls_history_raw>).

      APPEND VALUE ty_history(

        requestid =
          |{ <ls_history_raw>-RequestId }|

        statusseq =
          |{ <ls_history_raw>-StatusSequence }|

        status =
          |{ <ls_history_raw>-Status }|

        statusdate =
          |{ <ls_history_raw>-StatusDate }|

        changedby =
          |{ <ls_history_raw>-ChangedBy }|

        comments =
          |{ <ls_history_raw>-Comments }|

        statustext =
          |{ <ls_history_raw>-StatusText }|

      ) TO gt_history.

    ENDLOOP.

*---------------------------------------------------------------------*
* 15. SORT HISTORY
*---------------------------------------------------------------------*

    SORT gt_history BY statusseq DESCENDING.

*---------------------------------------------------------------------*
* 16. READ LATEST HISTORY
*---------------------------------------------------------------------*

    READ TABLE gt_history
      INDEX 1
      INTO DATA(ls_latest).

*---------------------------------------------------------------------*
* 17. APPEND REQUEST
*---------------------------------------------------------------------*

    IF sy-subrc = 0.

      APPEND VALUE ty_request(

        requestid =
          lv_requestid

        employeeid =
          lv_employeeid

        requesttype =
          lv_type

        priority =
          lv_priority

        status =
          lv_status

        statustext =
          lv_statustext

        materialid =
          lv_material

        quantity =
          lv_quantity

        reason =
          lv_reason

        requestdate =
          lv_reqdate

        requireddate =
          lv_reqdate2

        latest_date =
          ls_latest-statusdate

        changed_by =
          ls_latest-changedby

        comments =
          ls_latest-comments

      ) TO gt_requests.

    ELSE.

      APPEND VALUE ty_request(

        requestid =
          lv_requestid

        employeeid =
          lv_employeeid

        requesttype =
          lv_type

        priority =
          lv_priority

        status =
          lv_status

        statustext =
          lv_statustext

        materialid =
          lv_material

        quantity =
          lv_quantity

        reason =
          lv_reason

        requestdate =
          lv_reqdate

        requireddate =
          lv_reqdate2

        latest_date =
          'NO HISTORY'

        changed_by =
          'N/A'

        comments =
          'No status history'

      ) TO gt_requests.

    ENDIF.

  ENDLOOP.

*---------------------------------------------------------------------*
* 18. CREATE SALV
*---------------------------------------------------------------------*

  TRY.

      cl_salv_table=>factory(

        IMPORTING

          r_salv_table = DATA(lo_alv)

        CHANGING

          t_table = gt_requests ).

*---------------------------------------------------------------------*
* Standard functions
*---------------------------------------------------------------------*

      lo_alv->get_functions( )->set_all(
        abap_true ).

*---------------------------------------------------------------------*
* Events
*---------------------------------------------------------------------*

      DATA(lo_events) =
        lo_alv->get_event( ).

      DATA(lo_handler) =
        NEW lcl_dashboard_events( ).

      SET HANDLER
        lo_handler->on_double_click
        FOR lo_events.

*---------------------------------------------------------------------*
* Optimize
*---------------------------------------------------------------------*

      DATA(lo_columns) =
        lo_alv->get_columns( ).

      lo_columns->set_optimize(
        abap_true ).

*---------------------------------------------------------------------*
* Title
*---------------------------------------------------------------------*

      lo_alv->get_display_settings( )->set_list_header(

        'ESR REQUEST MANAGEMENT DASHBOARD' ).

*---------------------------------------------------------------------*
* Request ID
*---------------------------------------------------------------------*

      DATA(lo_column) =
        lo_columns->get_column(
          'REQUESTID' ).

      lo_column->set_short_text(
        'Req. ID' ).

      lo_column->set_medium_text(
        'Request ID' ).

      lo_column->set_long_text(
        'ESR Request ID' ).

*---------------------------------------------------------------------*
* Employee
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'EMPLOYEEID' ).

      lo_column->set_short_text(
        'Employee' ).

      lo_column->set_medium_text(
        'Employee ID' ).

      lo_column->set_long_text(
        'Employee ID' ).

*---------------------------------------------------------------------*
* Type
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'REQUESTTYPE' ).

      lo_column->set_short_text(
        'Type' ).

      lo_column->set_medium_text(
        'Request Type' ).

      lo_column->set_long_text(
        'Request Type' ).

*---------------------------------------------------------------------*
* Priority
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'PRIORITY' ).

      lo_column->set_short_text(
        'Priority' ).

      lo_column->set_medium_text(
        'Priority' ).

      lo_column->set_long_text(
        'Request Priority' ).

*---------------------------------------------------------------------*
* Status
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'STATUSTEXT' ).

      lo_column->set_short_text(
        'Status' ).

      lo_column->set_medium_text(
        'Current Status' ).

      lo_column->set_long_text(
        'Current Request Status' ).

*---------------------------------------------------------------------*
* Material
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'MATERIALID' ).

      lo_column->set_short_text(
        'Material' ).

      lo_column->set_medium_text(
        'Material ID' ).

      lo_column->set_long_text(
        'Requested Material ID' ).

*---------------------------------------------------------------------*
* Quantity
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'QUANTITY' ).

      lo_column->set_short_text(
        'Qty' ).

      lo_column->set_medium_text(
        'Quantity' ).

      lo_column->set_long_text(
        'Requested Quantity' ).

*---------------------------------------------------------------------*
* Reason
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'REASON' ).

      lo_column->set_short_text(
        'Reason' ).

      lo_column->set_medium_text(
        'Request Reason' ).

      lo_column->set_long_text(
        'Request Reason' ).

*---------------------------------------------------------------------*
* Request Date
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'REQUESTDATE' ).

      lo_column->set_short_text(
        'Created' ).

      lo_column->set_medium_text(
        'Request Date' ).

      lo_column->set_long_text(
        'Request Creation Date' ).

*---------------------------------------------------------------------*
* Required Date
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'REQUIREDDATE' ).

      lo_column->set_short_text(
        'Required' ).

      lo_column->set_medium_text(
        'Required Date' ).

      lo_column->set_long_text(
        'Required Date' ).

*---------------------------------------------------------------------*
* Latest Date
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'LATEST_DATE' ).

      lo_column->set_short_text(
        'Updated' ).

      lo_column->set_medium_text(
        'Last Updated' ).

      lo_column->set_long_text(
        'Latest Status Date' ).

*---------------------------------------------------------------------*
* Changed By
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'CHANGED_BY' ).

      lo_column->set_short_text(
        'Changed By' ).

      lo_column->set_medium_text(
        'Status Changed By' ).

      lo_column->set_long_text(
        'Latest Status Changed By' ).

*---------------------------------------------------------------------*
* Comments
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column(
          'COMMENTS' ).

      lo_column->set_short_text(
        'Comments' ).

      lo_column->set_medium_text(
        'Latest Comments' ).

      lo_column->set_long_text(
        'Latest Status Comments' ).

*---------------------------------------------------------------------*
* Display
*---------------------------------------------------------------------*

      lo_alv->display( ).

*---------------------------------------------------------------------*
* Exception
*---------------------------------------------------------------------*

    CATCH cx_salv_msg INTO DATA(lx_error).

      MESSAGE
        lx_error->get_text( )
        TYPE 'E'.

  ENDTRY.