*&---------------------------------------------------------------------*
*& Report ZESR_TEST_DUPLICATE
*&---------------------------------------------------------------------*
*& Test program for duplicate request validation
*&---------------------------------------------------------------------*

REPORT zesr_test_duplicate.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*

PARAMETERS:
  p_emp TYPE zesr_de_emp DEFAULT 'E1001',
  p_mat TYPE zesr_item-material_id DEFAULT 'LAPTOP-001'.

*---------------------------------------------------------------------*
* Data
*---------------------------------------------------------------------*

DATA:
  lo_request    TYPE REF TO zcl_esr_request,
  lv_duplicate  TYPE abap_bool,
  lv_request_id TYPE zesr_de_reqid.

*---------------------------------------------------------------------*
* Start of Selection
*---------------------------------------------------------------------*

START-OF-SELECTION.

  "Create object reference
  lo_request = NEW zcl_esr_request( ).

  "Call duplicate-checking business logic
  lo_request->check_duplicate(
    EXPORTING
      iv_employee_id = p_emp
      iv_material_id = p_mat
    IMPORTING
      ev_duplicate   = lv_duplicate
      ev_request_id  = lv_request_id ).

*---------------------------------------------------------------------*
* Display Result
*---------------------------------------------------------------------*

  WRITE: / '============================================'.
  WRITE: / '      ESR DUPLICATE REQUEST VALIDATION'.
  WRITE: / '============================================'.
  WRITE: / 'Employee ID :', p_emp.
  WRITE: / 'Material ID :', p_mat.
  WRITE: / '--------------------------------------------'.

  IF lv_duplicate = abap_true.

    WRITE: / 'RESULT      : DUPLICATE REQUEST DETECTED'.
    WRITE: / 'STATUS      : REQUEST BLOCKED'.
    WRITE: / 'EXISTING ID :', lv_request_id.
    WRITE: / '--------------------------------------------'.
    WRITE: / 'Employee already has an active request'.
    WRITE: / 'for this material.'.

  ELSE.

    WRITE: / 'RESULT      : NO DUPLICATE FOUND'.
    WRITE: / 'STATUS      : REQUEST CAN BE CREATED'.
    WRITE: / '--------------------------------------------'.
    WRITE: / 'No active request exists for this'.
    WRITE: / 'employee and material combination.'.

  ENDIF.