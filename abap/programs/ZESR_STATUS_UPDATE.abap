
*&---------------------------------------------------------------------*
*& Report ZESR_STATUS_UPDATE
*&---------------------------------------------------------------------*
*& ESR REQUEST - STATUS UPDATE / WORKFLOW
*&---------------------------------------------------------------------*

REPORT zesr_status_update.

*---------------------------------------------------------------------*
* 1. Selection Screen
*---------------------------------------------------------------------*

PARAMETERS:

  p_reqid TYPE zesr_de_reqid OBLIGATORY,

  p_status TYPE zesr_de_status
            AS LISTBOX VISIBLE LENGTH 20,

  p_comm TYPE zesr_status-comments
          LOWER CASE.


*---------------------------------------------------------------------*
* 2. Populate Status Dropdown
*---------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.

  DATA:
    lt_status TYPE vrm_values,
    ls_status TYPE vrm_value.

  CLEAR lt_status.

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
* Set dropdown
*---------------------------------------------------------------------*

  CALL FUNCTION 'VRM_SET_VALUES'

    EXPORTING

      id     = 'P_STATUS'
      values = lt_status.


*---------------------------------------------------------------------*
* 3. Start of Selection
*---------------------------------------------------------------------*

START-OF-SELECTION.

*---------------------------------------------------------------------*
* Variables
*---------------------------------------------------------------------*

  DATA:

    lv_current_status TYPE zesr_hdr-status,

    lv_next_seq       TYPE zesr_status-status_seq,

    lv_status_text    TYPE string,

    lv_comments       TYPE zesr_status-comments,

    ls_status         TYPE zesr_status.


*---------------------------------------------------------------------*
* 4. Check Whether Request Exists
*---------------------------------------------------------------------*

  SELECT SINGLE

    FROM zesr_hdr

    FIELDS status

    WHERE request_id = @p_reqid

    INTO @lv_current_status.


  IF sy-subrc <> 0.

    MESSAGE
      |Request { p_reqid } does not exist.|
      TYPE 'I'.

    RETURN.

  ENDIF.


*---------------------------------------------------------------------*
* 5. Check Whether Request Is Already Fulfilled
*---------------------------------------------------------------------*

  IF lv_current_status = 'F'.

    MESSAGE
      'Fulfilled request cannot be changed further.'
      TYPE 'I'.

    RETURN.

  ENDIF.


*---------------------------------------------------------------------*
* 6. Check Same Status
*---------------------------------------------------------------------*

  IF lv_current_status = p_status.

    MESSAGE
      |Request is already in the selected status - { p_reqid } - { p_status }|
      TYPE 'I'.

    RETURN.

  ENDIF.


*---------------------------------------------------------------------*
* 7. Convert Status to Text
*---------------------------------------------------------------------*

  CASE p_status.

    WHEN 'S'.

      lv_status_text = 'Submitted'.

    WHEN 'V'.

      lv_status_text = 'Validated'.

    WHEN 'P'.

      lv_status_text = 'Processing'.

    WHEN 'F'.

      lv_status_text = 'Fulfilled'.

    WHEN OTHERS.

      lv_status_text = 'Unknown'.

  ENDCASE.


*---------------------------------------------------------------------*
* 8. Update Current Status in ZESR_HDR
*---------------------------------------------------------------------*

  UPDATE zesr_hdr

    SET status = @p_status

    WHERE request_id = @p_reqid.


  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE
      'Unable to update request status.'
      TYPE 'E'.

    RETURN.

  ENDIF.


*---------------------------------------------------------------------*
* 9. Find Next Status Sequence
*---------------------------------------------------------------------*

  CLEAR lv_next_seq.

  SELECT SINGLE

    FROM zesr_status

    FIELDS MAX( status_seq )

    WHERE request_id = @p_reqid

    INTO @lv_next_seq.


  IF lv_next_seq IS INITIAL.

    lv_next_seq = 10.

  ELSE.

    lv_next_seq = lv_next_seq + 10.

  ENDIF.


*---------------------------------------------------------------------*
* 10. Prepare Status History Record
*---------------------------------------------------------------------*

  CLEAR ls_status.

  ls_status-request_id  = p_reqid.
  ls_status-status_seq  = lv_next_seq.
  ls_status-status      = p_status.
  ls_status-status_date = sy-datum.
  ls_status-changed_by  = sy-uname.
  ls_status-comments    = p_comm.


*---------------------------------------------------------------------*
* 11. Insert Status History
*---------------------------------------------------------------------*

  INSERT zesr_status FROM ls_status.


  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE
      'Status updated failed because status history could not be inserted.'
      TYPE 'E'.

    RETURN.

  ENDIF.


*---------------------------------------------------------------------*
* 12. Commit Both Changes
*---------------------------------------------------------------------*

  COMMIT WORK AND WAIT.


*---------------------------------------------------------------------*
* 13. Success Message
*---------------------------------------------------------------------*

  MESSAGE
    |Request { p_reqid } updated to { lv_status_text }.|
    TYPE 'S'.