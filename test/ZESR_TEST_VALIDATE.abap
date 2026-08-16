*&---------------------------------------------------------------------*
*& Report ZESR_TEST_VALIDATE
*&---------------------------------------------------------------------*
*& Test program for ESR request validation
*&---------------------------------------------------------------------*

REPORT zesr_test_validate.

PARAMETERS:
  p_reqid TYPE zesr_de_reqid DEFAULT '100004'.

DATA:
  lo_request TYPE REF TO zcl_esr_request,
  lv_success TYPE abap_bool,
  lv_message TYPE string.

START-OF-SELECTION.

  "---------------------------------------------------------------
  " Create business logic object
  "---------------------------------------------------------------

  lo_request = NEW zcl_esr_request( ).

  "---------------------------------------------------------------
  " Validate request
  "---------------------------------------------------------------

  lo_request->validate_request(
    EXPORTING
      iv_request_id = p_reqid
    IMPORTING
      ev_success    = lv_success
      ev_message    = lv_message ).

  "---------------------------------------------------------------
  " Display result
  "---------------------------------------------------------------

  WRITE: / '============================================'.
  WRITE: / '       ESR REQUEST VALIDATION'.
  WRITE: / '============================================'.
  WRITE: / 'Request ID     :', p_reqid.
  WRITE: / '--------------------------------------------'.

  IF lv_success = abap_true.

    WRITE: / 'RESULT         : REQUEST VALIDATED'.
    WRITE: / 'MESSAGE        :', lv_message.

  ELSE.

    WRITE: / 'RESULT         : VALIDATION FAILED'.
    WRITE: / 'MESSAGE        :', lv_message.

  ENDIF.

  WRITE: / '============================================'.