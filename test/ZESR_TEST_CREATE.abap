*&---------------------------------------------------------------------*
*& Report ZESR_TEST_CREATE
*&---------------------------------------------------------------------*
*& Test program for ESR request creation
*&---------------------------------------------------------------------*

REPORT zesr_test_create.

PARAMETERS:
  p_emp  TYPE zesr_de_emp      DEFAULT 'E9999',
  p_type TYPE zesr_de_rtype    DEFAULT 'N',
  p_prio TYPE zesr_de_priority DEFAULT 'N',
  p_mat  TYPE char40           DEFAULT 'MONITOR-001',
  p_qty  TYPE zesr_de_qty      DEFAULT '1',
  p_reqd TYPE dats             DEFAULT sy-datum,
  p_reas TYPE zesr_de_reason   DEFAULT 'New monitor required'.

DATA:
  lo_request    TYPE REF TO zcl_esr_request,
  lv_success    TYPE abap_bool,
  lv_request_id TYPE zesr_de_reqid,
  lv_message    TYPE string.

START-OF-SELECTION.

  "---------------------------------------------------------------
  " Create business logic object
  "---------------------------------------------------------------

  lo_request = NEW zcl_esr_request( ).

  "---------------------------------------------------------------
  " Create request
  "---------------------------------------------------------------

  lo_request->create_request(
    EXPORTING
      iv_employee_id   = p_emp
      iv_request_type  = p_type
      iv_priority      = p_prio
      iv_material_id   = p_mat
      iv_quantity      = p_qty
      iv_reason        = p_reas
      iv_required_date = p_reqd
    IMPORTING
      ev_success       = lv_success
      ev_request_id    = lv_request_id
      ev_message       = lv_message ).

  "---------------------------------------------------------------
  " Display result
  "---------------------------------------------------------------

  WRITE: / '============================================'.
  WRITE: / '       ESR REQUEST CREATION'.
  WRITE: / '============================================'.
  WRITE: / 'Employee ID    :', p_emp.
  WRITE: / 'Request Type   :', p_type.
  WRITE: / 'Priority       :', p_prio.
  WRITE: / 'Material ID    :', p_mat.
  WRITE: / 'Quantity       :', p_qty.
  WRITE: / 'Required Date  :', p_reqd.
  WRITE: / '--------------------------------------------'.

  IF lv_success = abap_true.

    WRITE: / 'RESULT         : REQUEST CREATED'.
    WRITE: / 'REQUEST ID     :', lv_request_id.
    WRITE: / 'MESSAGE        :', lv_message.

  ELSE.

    WRITE: / 'RESULT         : REQUEST NOT CREATED'.
    WRITE: / 'EXISTING ID    :', lv_request_id.
    WRITE: / 'MESSAGE        :', lv_message.

  ENDIF.

  WRITE: / '============================================'.