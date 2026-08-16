*&---------------------------------------------------------------------*
*& Report zesr_test_process
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_test_process.

PARAMETERS:
  p_reqid TYPE zesr_de_reqid DEFAULT '100004'.

DATA:
  lo_request TYPE REF TO zcl_esr_request,
  lv_success  TYPE abap_bool,
  lv_message  TYPE string.

START-OF-SELECTION.

  "---------------------------------------------------------------
  " Create business logic object
  "---------------------------------------------------------------

  lo_request = NEW zcl_esr_request( ).

  "---------------------------------------------------------------
  " Process request
  "---------------------------------------------------------------

  lo_request->process_request(
    EXPORTING
      iv_request_id = p_reqid
    IMPORTING
      ev_success    = lv_success
      ev_message    = lv_message ).

  "---------------------------------------------------------------
  " Display result
  "---------------------------------------------------------------

  WRITE: / '============================================'.
  WRITE: / '       ESR REQUEST PROCESSING'.
  WRITE: / '============================================'.
  WRITE: / 'Request ID     :', p_reqid.
  WRITE: / '--------------------------------------------'.

  IF lv_success = abap_true.

    WRITE: / 'RESULT         : REQUEST PROCESSING'.
    WRITE: / 'MESSAGE        :', lv_message.

  ELSE.

    WRITE: / 'RESULT         : PROCESSING FAILED'.
    WRITE: / 'MESSAGE        :', lv_message.

  ENDIF.

  WRITE: / '============================================'.