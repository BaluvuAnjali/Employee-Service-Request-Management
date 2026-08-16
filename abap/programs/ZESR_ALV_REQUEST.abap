*&---------------------------------------------------------------------*
*& Report ZESR_ALV_REQUEST
*&---------------------------------------------------------------------*
*& ESR REQUEST MONITOR
*&---------------------------------------------------------------------*
REPORT zesr_alv_request.

*---------------------------------------------------------------------*
* 1. ALV Output Structure
*---------------------------------------------------------------------*

TYPES: BEGIN OF ty_request,

         requestid    TYPE char20,
         employeeid   TYPE char20,
         requesttype  TYPE char20,
         priority     TYPE char20,
         status       TYPE char10,
         statustext   TYPE char30,
         status_icon  TYPE char20,
         materialid   TYPE char40,
         quantity     TYPE char20,
         reason       TYPE char100,
         requestdate  TYPE char20,
         requireddate TYPE char20,

       END OF ty_request.

*---------------------------------------------------------------------*
* 2. Global Internal Table
*---------------------------------------------------------------------*

DATA gt_requests TYPE STANDARD TABLE OF ty_request
                 WITH EMPTY KEY.

*---------------------------------------------------------------------*
* 3. Local Event Handler Class
*---------------------------------------------------------------------*

CLASS lcl_esr_alv_events DEFINITION.

  PUBLIC SECTION.

    METHODS on_double_click
      FOR EVENT double_click OF cl_salv_events_table
      IMPORTING
        row
        column.

ENDCLASS.

*---------------------------------------------------------------------*
* 4. Event Handler Implementation
*---------------------------------------------------------------------*

CLASS lcl_esr_alv_events IMPLEMENTATION.

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

      MESSAGE 'Unable to read selected request.' TYPE 'I'.

      RETURN.

    ENDIF.

*---------------------------------------------------------------------*
* Only Request ID supports detailed display
*---------------------------------------------------------------------*

    IF column <> 'REQUESTID'.

      MESSAGE 'Please double-click the Request ID.' TYPE 'I'.

      RETURN.

    ENDIF.

*---------------------------------------------------------------------*
* Prepare detailed information
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
      |Required Date: { ls_request-requireddate }|.

*---------------------------------------------------------------------*
* Display information
*---------------------------------------------------------------------*

    MESSAGE lv_message TYPE 'I'.

  ENDMETHOD.

ENDCLASS.

*---------------------------------------------------------------------*
* 5. Selection Screen
*---------------------------------------------------------------------*

PARAMETERS:

  p_emp TYPE zesr_de_emp,

  p_status TYPE zesr_de_status
           AS LISTBOX VISIBLE LENGTH 20.

*---------------------------------------------------------------------*
* 6. Default Status
*---------------------------------------------------------------------*

INITIALIZATION.

  p_status = 'S'.

*---------------------------------------------------------------------*
* 7. Populate Status Dropdown
*---------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.

  DATA:
    lt_status TYPE vrm_values,
    ls_status TYPE vrm_value.

  CLEAR lt_status.

*---------------------------------------------------------------------*
* All Statuses
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
* Set Dropdown Values
*---------------------------------------------------------------------*

  CALL FUNCTION 'VRM_SET_VALUES'

    EXPORTING
      id     = 'P_STATUS'
      values = lt_status.

*---------------------------------------------------------------------*
* 8. Start of Selection
*---------------------------------------------------------------------*

START-OF-SELECTION.

*---------------------------------------------------------------------*
* 9. Read CDS View
*
* IMPORTANT:
* Do NOT use:
* DATA lt_db TYPE TABLE OF zesr_c_request.
*
* Each field is selected individually into its own variable.
*---------------------------------------------------------------------*

  SELECT
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

    FROM zesr_c_request

    WHERE
      ( EmployeeId = @p_emp
        OR @p_emp IS INITIAL )

      AND

      ( Status = @p_status
        OR @p_status IS INITIAL )

    INTO TABLE @DATA(lt_db).

*---------------------------------------------------------------------*
* 10. No Data Check
*---------------------------------------------------------------------*

  IF lt_db IS INITIAL.

    MESSAGE 'No ESR requests found.' TYPE 'I'.

    RETURN.

  ENDIF.

*---------------------------------------------------------------------*
* 11. Convert CDS Data to ALV Structure
*---------------------------------------------------------------------*

  LOOP AT lt_db ASSIGNING FIELD-SYMBOL(<ls_db>).

    DATA(ls_request) = VALUE ty_request( ).

*---------------------------------------------------------------------*
* Request ID
*---------------------------------------------------------------------*

    ls_request-requestid =
      |{ <ls_db>-RequestId }|.

*---------------------------------------------------------------------*
* Employee ID
*---------------------------------------------------------------------*

    ls_request-employeeid =
      |{ <ls_db>-EmployeeId }|.

*---------------------------------------------------------------------*
* Request Type
*---------------------------------------------------------------------*

    ls_request-requesttype =
      |{ <ls_db>-RequestType }|.

*---------------------------------------------------------------------*
* Priority
*---------------------------------------------------------------------*

    ls_request-priority =
      |{ <ls_db>-Priority }|.

*---------------------------------------------------------------------*
* Status Code
*---------------------------------------------------------------------*

    ls_request-status =
      |{ <ls_db>-Status }|.

*---------------------------------------------------------------------*
* Status Text
*---------------------------------------------------------------------*

    ls_request-statustext =
      |{ <ls_db>-StatusText }|.

*---------------------------------------------------------------------*
* Material ID
*---------------------------------------------------------------------*

    ls_request-materialid =
      |{ <ls_db>-MaterialId }|.

*---------------------------------------------------------------------*
* Quantity
*---------------------------------------------------------------------*

    ls_request-quantity =
      |{ <ls_db>-Quantity }|.

*---------------------------------------------------------------------*
* Reason
*---------------------------------------------------------------------*

    ls_request-reason =
      |{ <ls_db>-Reason }|.

*---------------------------------------------------------------------*
* Request Date
*---------------------------------------------------------------------*

    ls_request-requestdate =
      |{ <ls_db>-RequestDate }|.

*---------------------------------------------------------------------*
* Required Date
*---------------------------------------------------------------------*

    ls_request-requireddate =
      |{ <ls_db>-RequiredDate }|.

*---------------------------------------------------------------------*
* Status Indicator
*---------------------------------------------------------------------*

    CASE ls_request-status.

      WHEN 'S'.

        ls_request-status_icon = 'SUBMITTED'.

      WHEN 'V'.

        ls_request-status_icon = 'VALIDATED'.

      WHEN 'P'.

        ls_request-status_icon = 'PROCESSING'.

      WHEN 'F'.

        ls_request-status_icon = 'FULFILLED'.

      WHEN OTHERS.

        ls_request-status_icon = 'UNKNOWN'.

    ENDCASE.

*---------------------------------------------------------------------*
* Append ALV Row
*---------------------------------------------------------------------*

    APPEND ls_request TO gt_requests.

  ENDLOOP.

*---------------------------------------------------------------------*
* 12. Create SALV
*---------------------------------------------------------------------*

  TRY.

      cl_salv_table=>factory(

        IMPORTING
          r_salv_table = DATA(lo_alv)

        CHANGING
          t_table = gt_requests ).

*---------------------------------------------------------------------*
* 13. Enable Standard ALV Functions
*---------------------------------------------------------------------*

      lo_alv->get_functions( )->set_all( abap_true ).

*---------------------------------------------------------------------*
* 14. Register Double Click Event
*---------------------------------------------------------------------*

      DATA(lo_events) = lo_alv->get_event( ).

      DATA(lo_handler) = NEW lcl_esr_alv_events( ).

      SET HANDLER lo_handler->on_double_click
        FOR lo_events.

*---------------------------------------------------------------------*
* 15. Optimize Columns
*---------------------------------------------------------------------*

      DATA(lo_columns) = lo_alv->get_columns( ).

      lo_columns->set_optimize( abap_true ).

*---------------------------------------------------------------------*
* 16. ALV Title
*---------------------------------------------------------------------*

      lo_alv->get_display_settings( )->set_list_header(
        'ESR REQUEST MONITOR' ).

*---------------------------------------------------------------------*
* 17. Request ID
*---------------------------------------------------------------------*

      DATA(lo_column) =
        lo_columns->get_column( 'REQUESTID' ).

      lo_column->set_short_text( 'Req. ID' ).

      lo_column->set_medium_text( 'Request ID' ).

      lo_column->set_long_text( 'ESR Request ID' ).

*---------------------------------------------------------------------*
* 18. Employee
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'EMPLOYEEID' ).

      lo_column->set_short_text( 'Employee' ).

      lo_column->set_medium_text( 'Employee ID' ).

      lo_column->set_long_text( 'Employee ID' ).

*---------------------------------------------------------------------*
* 19. Request Type
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'REQUESTTYPE' ).

      lo_column->set_short_text( 'Type' ).

      lo_column->set_medium_text( 'Request Type' ).

      lo_column->set_long_text( 'Request Type' ).

*---------------------------------------------------------------------*
* 20. Priority
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'PRIORITY' ).

      lo_column->set_short_text( 'Priority' ).

      lo_column->set_medium_text( 'Priority' ).

      lo_column->set_long_text( 'Request Priority' ).

*---------------------------------------------------------------------*
* 21. Status
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'STATUSTEXT' ).

      lo_column->set_short_text( 'Status' ).

      lo_column->set_medium_text( 'Status' ).

      lo_column->set_long_text( 'Current Status' ).

*---------------------------------------------------------------------*
* 22. Status Indicator
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'STATUS_ICON' ).

      lo_column->set_short_text( 'Indicator' ).

      lo_column->set_medium_text( 'Status Indicator' ).

      lo_column->set_long_text( 'ESR Status Indicator' ).

*---------------------------------------------------------------------*
* 23. Material
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'MATERIALID' ).

      lo_column->set_short_text( 'Material' ).

      lo_column->set_medium_text( 'Material ID' ).

      lo_column->set_long_text( 'Material ID' ).

*---------------------------------------------------------------------*
* 24. Quantity
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'QUANTITY' ).

      lo_column->set_short_text( 'Qty' ).

      lo_column->set_medium_text( 'Quantity' ).

      lo_column->set_long_text( 'Requested Quantity' ).

*---------------------------------------------------------------------*
* 25. Reason
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'REASON' ).

      lo_column->set_short_text( 'Reason' ).

      lo_column->set_medium_text( 'Request Reason' ).

      lo_column->set_long_text( 'Request Reason' ).

*---------------------------------------------------------------------*
* 26. Request Date
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'REQUESTDATE' ).

      lo_column->set_short_text( 'Req. Date' ).

      lo_column->set_medium_text( 'Request Date' ).

      lo_column->set_long_text( 'Request Creation Date' ).

*---------------------------------------------------------------------*
* 27. Required Date
*---------------------------------------------------------------------*

      lo_column =
        lo_columns->get_column( 'REQUIREDDATE' ).

      lo_column->set_short_text( 'Required' ).

      lo_column->set_medium_text( 'Required Date' ).

      lo_column->set_long_text( 'Required Date' ).

*---------------------------------------------------------------------*
* 28. Display ALV
*---------------------------------------------------------------------*

      lo_alv->display( ).

*---------------------------------------------------------------------*
* 29. Exception Handling
*---------------------------------------------------------------------*

    CATCH cx_salv_msg INTO DATA(lx_error).

      MESSAGE lx_error->get_text( ) TYPE 'E'.

  ENDTRY.