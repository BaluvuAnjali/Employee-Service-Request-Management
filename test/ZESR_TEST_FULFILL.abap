*&---------------------------------------------------------------------*
*& Report zesr_test_fulfill
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_test_fulfill.

PARAMETERS p_reqid TYPE zesr_de_reqid DEFAULT '100004'.

DATA:
  lo_request TYPE REF TO zcl_esr_request,
  lv_success TYPE abap_bool,
  lv_message TYPE string.

START-OF-SELECTION.

  CREATE OBJECT lo_request.

  lo_request->fulfill_request(
    EXPORTING
      iv_request_id = p_reqid
    IMPORTING
      ev_success    = lv_success
      ev_message    = lv_message ).

  WRITE: / '============================================'.
  WRITE: / '       ESR REQUEST FULFILLMENT'.
  WRITE: / '============================================'.
  WRITE: / 'Request ID :', p_reqid.

  IF lv_success = abap_true.

    WRITE: / 'RESULT     : REQUEST FULFILLED'.

  ELSE.

    WRITE: / 'RESULT     : FULFILLMENT FAILED'.

  ENDIF.

  WRITE: / 'MESSAGE    :', lv_message.
  WRITE: / '============================================'.