*&---------------------------------------------------------------------*
*& Report zesr_test_details
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_test_details.

PARAMETERS p_reqid TYPE zesr_de_reqid DEFAULT '100004'.

DATA:
  lo_request      TYPE REF TO zcl_esr_request,
  lv_success      TYPE abap_bool,
  lv_employee_id  TYPE zesr_de_emp,
  lv_request_type TYPE zesr_de_rtype,
  lv_priority     TYPE zesr_de_priority,
  lv_material_id  TYPE char40,
  lv_quantity     TYPE zesr_de_qty,
  lv_required_date TYPE dats,
  lv_status       TYPE zesr_de_status,
  lv_message      TYPE string.

START-OF-SELECTION.

  CREATE OBJECT lo_request.

  lo_request->get_request_details(
    EXPORTING
      iv_request_id    = p_reqid
    IMPORTING
      ev_success       = lv_success
      ev_employee_id   = lv_employee_id
      ev_request_type  = lv_request_type
      ev_priority      = lv_priority
      ev_material_id   = lv_material_id
      ev_quantity      = lv_quantity
      ev_required_date = lv_required_date
      ev_status        = lv_status
      ev_message       = lv_message ).

  WRITE: / '============================================'.
  WRITE: / '       ESR REQUEST DETAILS'.
  WRITE: / '============================================'.
  WRITE: / 'Request ID     :', p_reqid.

  IF lv_success = abap_true.

    WRITE: / 'Employee ID    :', lv_employee_id.
    WRITE: / 'Request Type   :', lv_request_type.
    WRITE: / 'Priority       :', lv_priority.
    WRITE: / 'Material ID    :', lv_material_id.
    WRITE: / 'Quantity       :', lv_quantity.
    WRITE: / 'Required Date  :', lv_required_date.
    WRITE: / 'Current Status :', lv_status.
    WRITE: / 'RESULT         : DETAILS FOUND'.

  ELSE.

    WRITE: / 'RESULT         : DETAILS NOT FOUND'.

  ENDIF.

  WRITE: / 'MESSAGE        :', lv_message.
  WRITE: / '============================================'.