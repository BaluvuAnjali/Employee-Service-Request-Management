*&---------------------------------------------------------------------*
*& Report zesr_test_status
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_test_status.

PARAMETERS p_reqid TYPE zesr_de_reqid DEFAULT '100004'.

DATA:
  lo_request TYPE REF TO zcl_esr_request,
  lv_success TYPE abap_bool,
  lv_message TYPE string.

START-OF-SELECTION.

  CREATE OBJECT lo_request.

  lo_request->get_request_status(
    EXPORTING
      iv_request_id = p_reqid
    IMPORTING
      ev_success    = lv_success
      ev_message    = lv_message ).

  WRITE: / '============================================'.
  WRITE: / '       ESR REQUEST STATUS'.
  WRITE: / '============================================'.
  WRITE: / 'Request ID :', p_reqid.

  IF lv_success = abap_true.
    WRITE: / 'RESULT     : STATUS FOUND'.
  ELSE.
    WRITE: / 'RESULT     : STATUS NOT FOUND'.
  ENDIF.

  WRITE: / 'MESSAGE    :', lv_message.
  WRITE: / '============================================'.