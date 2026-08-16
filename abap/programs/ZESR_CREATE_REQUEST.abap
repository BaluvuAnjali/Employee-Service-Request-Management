*&---------------------------------------------------------------------*
*& Report ZESR_CREATE_REQUEST
*&---------------------------------------------------------------------*
*& ESR EMPLOYEE SERVICE REQUEST - CREATE REQUEST
*&---------------------------------------------------------------------*
REPORT zesr_create_request.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

PARAMETERS:
  p_emp  TYPE zesr_de_emp OBLIGATORY,
  p_type TYPE zesr_de_rtype OBLIGATORY,
  p_prio TYPE zesr_de_priority OBLIGATORY,
  p_mat  TYPE zesr_item-material_id OBLIGATORY,
  p_qty  TYPE zesr_de_qty OBLIGATORY,
  p_req  TYPE zesr_de_reason OBLIGATORY,
  p_date TYPE zesr_hdr-required_date OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.

*---------------------------------------------------------------------*
* Data Declarations
*---------------------------------------------------------------------*

DATA:
  lv_max_request TYPE zesr_hdr-request_id,
  lv_next_number TYPE i,
  lv_request_id  TYPE zesr_hdr-request_id,
  lv_duplicate   TYPE zesr_hdr-request_id,
  lv_next_seq    TYPE zesr_status-status_seq,
  lv_message     TYPE string.

DATA:
  ls_hdr    TYPE zesr_hdr,
  ls_item   TYPE zesr_item,
  ls_status TYPE zesr_status.

*---------------------------------------------------------------------*
* Start of Selection
*---------------------------------------------------------------------*

START-OF-SELECTION.

*---------------------------------------------------------------------*
* Validate Quantity
*---------------------------------------------------------------------*

  IF p_qty IS INITIAL.

    MESSAGE 'Quantity must be greater than zero.' TYPE 'E'.

  ENDIF.

  IF p_qty <= 0.

    MESSAGE 'Quantity must be greater than zero.' TYPE 'E'.

  ENDIF.

*---------------------------------------------------------------------*
* Validate Required Date
*---------------------------------------------------------------------*

  IF p_date < sy-datum.

    MESSAGE 'Required date cannot be before today.' TYPE 'E'.

  ENDIF.

*---------------------------------------------------------------------*
* Check Duplicate Active Request
*---------------------------------------------------------------------*

  CLEAR lv_duplicate.

  SELECT SINGLE
    h~request_id
    INTO lv_duplicate
    FROM zesr_hdr AS h
    INNER JOIN zesr_item AS i
      ON h~request_id = i~request_id
    WHERE h~employee_id = p_emp
      AND i~material_id = p_mat
      AND h~status IN ( 'S', 'V', 'P' ).

  IF sy-subrc = 0.

    lv_message =
      |Duplicate active request already exists: { lv_duplicate }|.

    MESSAGE lv_message TYPE 'E'.

  ENDIF.

*---------------------------------------------------------------------*
* Generate Next Request ID
*---------------------------------------------------------------------*

  CLEAR lv_max_request.

  SELECT SINGLE
    MAX( request_id )
    INTO lv_max_request
    FROM zesr_hdr.

  IF lv_max_request IS INITIAL.

    lv_next_number = 100001.

  ELSE.

    lv_next_number = CONV i( lv_max_request ).

    lv_next_number = lv_next_number + 1.

  ENDIF.

*---------------------------------------------------------------------*
* Convert Number to Request ID
*---------------------------------------------------------------------*

  lv_request_id =
    |{ lv_next_number WIDTH = 6 PAD = '0' }|.

*---------------------------------------------------------------------*
* Prepare Header
*---------------------------------------------------------------------*

  CLEAR ls_hdr.

  ls_hdr-request_id   = lv_request_id.
  ls_hdr-employee_id  = p_emp.
  ls_hdr-request_type = p_type.
  ls_hdr-priority     = p_prio.
  ls_hdr-status       = 'S'.
  ls_hdr-request_date = sy-datum.
  ls_hdr-required_date = p_date.

*---------------------------------------------------------------------*
* Insert Header
*---------------------------------------------------------------------*

  INSERT zesr_hdr FROM ls_hdr.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE
      'Unable to create request header.'
      TYPE 'E'.

  ENDIF.

*---------------------------------------------------------------------*
* Prepare Item
*---------------------------------------------------------------------*

  CLEAR ls_item.

  ls_item-request_id  = lv_request_id.
  ls_item-material_id = p_mat.
  ls_item-quantity    = p_qty.
  ls_item-reason      = p_req.

*---------------------------------------------------------------------*
* Insert Item
*---------------------------------------------------------------------*

  INSERT zesr_item FROM ls_item.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE
      'Unable to create request item.'
      TYPE 'E'.

  ENDIF.

*---------------------------------------------------------------------*
* Prepare Initial Status History
*---------------------------------------------------------------------*

  CLEAR ls_status.

  lv_next_seq = '0010'.

  ls_status-request_id  = lv_request_id.
  ls_status-status_seq  = lv_next_seq.
  ls_status-status      = 'S'.
  ls_status-status_date = sy-datum.
  ls_status-changed_by  = sy-uname.
  ls_status-comments    = 'Request submitted by employee'.

*---------------------------------------------------------------------*
* Insert Status History
*---------------------------------------------------------------------*

  INSERT zesr_status FROM ls_status.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE
      'Unable to create status history.'
      TYPE 'E'.

  ENDIF.

*---------------------------------------------------------------------*
* Commit Database Changes
*---------------------------------------------------------------------*

  COMMIT WORK AND WAIT.

*---------------------------------------------------------------------*
* Success Message
*---------------------------------------------------------------------*

  lv_message =
    |ESR Request { lv_request_id } created successfully. Status: Submitted|.

  MESSAGE lv_message TYPE 'S'.

*---------------------------------------------------------------------*
* Display Created Request
*---------------------------------------------------------------------*

  WRITE: / '===================================================='.
  WRITE: / '        ESR REQUEST CREATED SUCCESSFULLY'.
  WRITE: / '===================================================='.
  WRITE: /.
  WRITE: / 'Request ID       :', lv_request_id.
  WRITE: / 'Employee ID      :', p_emp.
  WRITE: / 'Request Type     :', p_type.
  WRITE: / 'Priority         :', p_prio.
  WRITE: / 'Material ID      :', p_mat.
  WRITE: / 'Quantity         :', p_qty.
  WRITE: / 'Reason           :', p_req.
  WRITE: / 'Request Date     :', sy-datum.
  WRITE: / 'Required Date    :', p_date.
  WRITE: / 'Status           : Submitted'.
  WRITE: / 'Status Sequence  :', lv_next_seq.
  WRITE: / 'Changed By       :', sy-uname.
  WRITE: /.
  WRITE: / '===================================================='.
  WRITE: / 'Request is now available in Fiori monitoring.'.
  WRITE: / '===================================================='.