CLASS zcl_esr_request DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .

PUBLIC SECTION.
METHODS check_duplicate
IMPORTING
iv_employee_id      TYPE zesr_de_emp
iv_material_id      TYPE char40
EXPORTING
ev_duplicate        TYPE abap_bool
ev_request_id       TYPE zesr_de_reqid.

 METHODS create_request
      IMPORTING
        iv_employee_id   TYPE zesr_de_emp
        iv_request_type  TYPE zesr_de_rtype
        iv_priority      TYPE zesr_de_priority
        iv_material_id   TYPE char40
        iv_quantity      TYPE zesr_de_qty
        iv_reason        TYPE zesr_de_reason
        iv_required_date TYPE dats
      EXPORTING
        ev_success       TYPE abap_bool
        ev_request_id    TYPE zesr_de_reqid
        ev_message       TYPE string.

METHODS validate_request
IMPORTING
iv_request_id TYPE zesr_de_reqid
EXPORTING
ev_success    TYPE abap_bool
ev_message    TYPE string.

METHODS process_request
IMPORTING
  iv_request_id TYPE zesr_de_reqid
EXPORTING
  ev_success    TYPE abap_bool
  ev_message    TYPE string.

METHODS fulfill_request
  IMPORTING
    iv_request_id TYPE zesr_de_reqid
  EXPORTING
    ev_success    TYPE abap_bool
    ev_message    TYPE string.

METHODS get_request_status
  IMPORTING
    iv_request_id TYPE zesr_de_reqid
  EXPORTING
    ev_success    TYPE abap_bool
    ev_message    TYPE string.

METHODS get_request_details
  IMPORTING
    iv_request_id TYPE zesr_de_reqid
  EXPORTING
    ev_success       TYPE abap_bool
    ev_employee_id   TYPE zesr_de_emp
    ev_request_type  TYPE zesr_de_rtype
    ev_priority      TYPE zesr_de_priority
    ev_material_id   TYPE char40
    ev_quantity      TYPE zesr_de_qty
    ev_required_date TYPE dats
    ev_status        TYPE zesr_de_status
    ev_message       TYPE string.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS zcl_esr_request
IMPLEMENTATION.
METHOD check_duplicate.

CLEAR: ev_duplicate,
       ev_request_id.

SELECT SINGLE FROM zesr_hdr AS h
INNER JOIN zesr_item AS i
ON h~request_id = i~request_id
FIELDS h~request_id
WHERE h~employee_id = @iv_employee_id
AND i~material_id = @iv_material_id
AND h~status IN ( 'S', 'V', 'P' )
INTO @ev_request_id.

IF sy-subrc = 0.
  ev_duplicate = abap_true.
ELSE.
  ev_duplicate = abap_false.
ENDIF.
ENDMETHOD.
  METHOD create_request.

 DATA:
  lv_duplicate      TYPE abap_bool,
  lv_existing_id    TYPE zesr_de_reqid,
  lv_max_request_id TYPE zesr_de_reqid,
  lv_max_item_id    TYPE zesr_de_reqid,
  lv_next_number    TYPE i,
  lv_new_request_id TYPE zesr_de_reqid.
  DATA:
      ls_hdr    TYPE zesr_hdr,
      ls_item   TYPE zesr_item,
      ls_status TYPE zesr_status.

    CLEAR:
      ev_success,
      ev_request_id,
      ev_message.

    "---------------------------------------------------------------
    " STEP 1: Check for duplicate active request
    "---------------------------------------------------------------

    me->check_duplicate(
      EXPORTING
        iv_employee_id = iv_employee_id
        iv_material_id = iv_material_id
      IMPORTING
        ev_duplicate   = lv_duplicate
        ev_request_id  = lv_existing_id ).

    IF lv_duplicate = abap_true.

      ev_success    = abap_false.
      ev_request_id = lv_existing_id.

      ev_message =
        |Duplicate request detected. Existing request: { lv_existing_id }|.

      RETURN.

    ENDIF.

    "---------------------------------------------------------------
" STEP 2: Generate next request ID
"---------------------------------------------------------------

SELECT SINGLE
  FROM zesr_hdr
  FIELDS MAX( request_id )
  INTO @lv_max_request_id.

SELECT SINGLE
  FROM zesr_item
  FIELDS MAX( request_id )
  INTO @lv_max_item_id.

IF lv_max_request_id IS INITIAL.
  lv_max_request_id = '000000'.
ENDIF.

IF lv_max_item_id IS INITIAL.
  lv_max_item_id = '000000'.
ENDIF.

IF lv_max_item_id > lv_max_request_id.
  lv_max_request_id = lv_max_item_id.
ENDIF.

lv_next_number = CONV i( lv_max_request_id ) + 1.

lv_new_request_id =
  |{ lv_next_number WIDTH = 6 PAD = '0' }|.
    "---------------------------------------------------------------
    " STEP 3: Prepare Header data
    "---------------------------------------------------------------

 ls_hdr = VALUE #(
  client        = sy-mandt
  request_id    = lv_new_request_id
  employee_id   = iv_employee_id
  request_type  = iv_request_type
  priority      = iv_priority
  status        = 'S'
  request_date  = sy-datum
  required_date = iv_required_date
  created_by    = sy-uname
  created_on    = sy-datum ).

    "---------------------------------------------------------------
    " STEP 4: Insert Header
    "---------------------------------------------------------------

    INSERT zesr_hdr FROM @ls_hdr.

    IF sy-subrc <> 0.

      ev_success = abap_false.

      ev_message =
        |Request header could not be created.|.

      RETURN.

    ENDIF.

    "---------------------------------------------------------------
    " STEP 5: Prepare Item data
    "---------------------------------------------------------------

ls_item = VALUE #(
  client      = sy-mandt
  request_id  = lv_new_request_id
  item_no     = '0010'
  material_id = iv_material_id
  quantity    = iv_quantity
  reason      = iv_reason
  item_status = 'S' ).

    "---------------------------------------------------------------
    " STEP 6: Insert Item
    "---------------------------------------------------------------

    INSERT zesr_item FROM @ls_item.

    IF sy-subrc <> 0.

      DATA(lv_subrc) = sy-subrc.

      ROLLBACK WORK.

      ev_success = abap_false.

      ev_message =
        |Request item could not be created. SY-SUBRC = { lv_subrc }|.

      RETURN.

    ENDIF.

    "---------------------------------------------------------------
    " STEP 7: Prepare initial status history
    "---------------------------------------------------------------

ls_status = VALUE #(
  client      = sy-mandt
  request_id  = lv_new_request_id
  status_seq  = '0010'
  status      = 'S'
  status_date = sy-datum
  changed_by  = sy-uname
  comments    = 'Request submitted by employee' ).
    "---------------------------------------------------------------
    " STEP 8: Insert status history
    "---------------------------------------------------------------

    INSERT zesr_status FROM @ls_status.

    IF sy-subrc <> 0.

      ROLLBACK WORK.

      ev_success = abap_false.

      ev_message =
        |Request status history could not be created.|.

      RETURN.

    ENDIF.

 COMMIT WORK.

    ev_success    = abap_true.
    ev_request_id = lv_new_request_id.

    ev_message =
      |Request { lv_new_request_id } created successfully.|.

  ENDMETHOD.

METHOD validate_request.

  DATA:
    ls_hdr       TYPE zesr_hdr,
    ls_status    TYPE zesr_status,
    lv_max_seq   TYPE zesr_status-status_seq,
    lv_next_num  TYPE i,
    lv_next_seq  TYPE zesr_status-status_seq.

  CLEAR:
    ev_success,
    ev_message.

  "---------------------------------------------------------------
  " STEP 1: Read request header
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_hdr
    FIELDS *
    WHERE request_id = @iv_request_id
    INTO @ls_hdr.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request { iv_request_id } does not exist.|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 2: Check current status
  "---------------------------------------------------------------

  IF ls_hdr-status <> 'S'.

    ev_success = abap_false.

    ev_message =
      |Request { iv_request_id } cannot be validated. Current status: { ls_hdr-status }|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 3: Update header status
  "---------------------------------------------------------------

  ls_hdr-status = 'V'.

  UPDATE zesr_hdr FROM @ls_hdr.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request header could not be updated.|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 4: Find latest status sequence
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_status
    FIELDS MAX( status_seq )
    WHERE request_id = @iv_request_id
    INTO @lv_max_seq.

  IF lv_max_seq IS INITIAL.

    lv_next_num = 10.

  ELSE.

    lv_next_num = CONV i( lv_max_seq ) + 10.

  ENDIF.

  lv_next_seq =
    |{ lv_next_num WIDTH = 4 PAD = '0' }|.

  "---------------------------------------------------------------
  " STEP 5: Prepare status history
  "---------------------------------------------------------------

  ls_status = VALUE #(
    client      = sy-mandt
    request_id  = iv_request_id
    status_seq  = lv_next_seq
    status      = 'V'
    status_date = sy-datum
    changed_by  = sy-uname
    comments    = 'Request validated successfully'
  ).

  "---------------------------------------------------------------
  " STEP 6: Insert status history
  "---------------------------------------------------------------

  INSERT zesr_status FROM @ls_status.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    ev_success = abap_false.

    ev_message =
      |Request status history could not be created.|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 7: Commit transaction
  "---------------------------------------------------------------

  COMMIT WORK.

  ev_success = abap_true.

  ev_message =
    |Request { iv_request_id } validated successfully.|.

ENDMETHOD.

METHOD process_request.

DATA:
  ls_hdr      TYPE zesr_hdr,
  ls_status   TYPE zesr_status,
  lv_max_seq  TYPE zesr_status-status_seq,
  lv_next_num TYPE i,
  lv_next_seq TYPE zesr_status-status_seq.

CLEAR:
  ev_success,
  ev_message.

"---------------------------------------------------------------
" STEP 1: Read request header
"---------------------------------------------------------------

SELECT SINGLE
  FROM zesr_hdr
  FIELDS *
  WHERE request_id = @iv_request_id
  INTO @ls_hdr.

IF sy-subrc <> 0.

  ev_success = abap_false.

  ev_message =
    |Request { iv_request_id } does not exist.|.

  RETURN.

ENDIF.

"---------------------------------------------------------------
" STEP 2: Check current status
"---------------------------------------------------------------

IF ls_hdr-status <> 'V'.

  ev_success = abap_false.

  ev_message =
    |Request { iv_request_id } cannot be processed. Current status: { ls_hdr-status }|.

  RETURN.

ENDIF.

"---------------------------------------------------------------
" STEP 3: Change status V -> P
"---------------------------------------------------------------

ls_hdr-status = 'P'.

UPDATE zesr_hdr FROM @ls_hdr.

IF sy-subrc <> 0.

  ev_success = abap_false.

  ev_message =
    |Request header could not be updated.|.

  RETURN.

ENDIF.

"---------------------------------------------------------------
" STEP 4: Find latest status sequence
"---------------------------------------------------------------

SELECT SINGLE
  FROM zesr_status
  FIELDS MAX( status_seq )
  WHERE request_id = @iv_request_id
  INTO @lv_max_seq.

IF lv_max_seq IS INITIAL.

  lv_next_num = 10.

ELSE.

  lv_next_num = CONV i( lv_max_seq ) + 10.

ENDIF.

lv_next_seq =
  |{ lv_next_num WIDTH = 4 PAD = '0' }|.

"---------------------------------------------------------------
" STEP 5: Prepare status history
"---------------------------------------------------------------

ls_status = VALUE #(
  client      = sy-mandt
  request_id  = iv_request_id
  status_seq  = lv_next_seq
  status      = 'P'
  status_date = sy-datum
  changed_by  = sy-uname
  comments    = 'Request is being processed'
).

"---------------------------------------------------------------
" STEP 6: Insert status history
"---------------------------------------------------------------

INSERT zesr_status FROM @ls_status.

IF sy-subrc <> 0.

  ROLLBACK WORK.

  ev_success = abap_false.

  ev_message =
    |Request status history could not be created.|.

  RETURN.

ENDIF.

"---------------------------------------------------------------
" STEP 7: Commit transaction
"---------------------------------------------------------------

COMMIT WORK.

ev_success = abap_true.

ev_message =
  |Request { iv_request_id } moved to processing successfully.|.

ENDMETHOD.

METHOD fulfill_request.

  DATA:
    ls_hdr       TYPE zesr_hdr,
    ls_item      TYPE zesr_item,
    ls_fulfill   TYPE zesr_fullfill,
    ls_status    TYPE zesr_status,
    lv_max_seq   TYPE zesr_status-status_seq,
    lv_next_num  TYPE i,
    lv_next_seq  TYPE zesr_status-status_seq.

  CLEAR:
    ev_success,
    ev_message.

  "---------------------------------------------------------------
  " STEP 1: Read request header
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_hdr
    FIELDS *
    WHERE request_id = @iv_request_id
    INTO @ls_hdr.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request { iv_request_id } does not exist.|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 2: Request must be in Processing status
  "---------------------------------------------------------------

  IF ls_hdr-status <> 'P'.

    ev_success = abap_false.

    ev_message =
      |Request { iv_request_id } cannot be fulfilled. Current status: { ls_hdr-status }|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 3: Read request item
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_item
    FIELDS *
    WHERE request_id = @iv_request_id
    INTO @ls_item.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request item for { iv_request_id } does not exist.|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 4: Prepare fulfillment data
  "---------------------------------------------------------------

  ls_fulfill = VALUE #(
    client         = sy-mandt
    request_id     = iv_request_id
    item_no        = ls_item-item_no
    material_id    = ls_item-material_id
    fulfilled_qty  = ls_item-quantity
    fulfill_date   = sy-datum
    fulfilled_by   = sy-uname
    fulfill_status = 'F'
  ).


  "---------------------------------------------------------------
  " STEP 5: Insert fulfillment record
  "---------------------------------------------------------------

  INSERT zesr_fullfill FROM @ls_fulfill.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Fulfillment record could not be created.|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 6: Update Header status P → F
  "---------------------------------------------------------------

  ls_hdr-status = 'F'.

  UPDATE zesr_hdr FROM @ls_hdr.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    ev_success = abap_false.

    ev_message =
      |Request header could not be updated.|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 7: Update Item status P → F
  "---------------------------------------------------------------

  ls_item-item_status = 'F'.

  UPDATE zesr_item FROM @ls_item.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    ev_success = abap_false.

    ev_message =
      |Request item could not be updated.|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 8: Find latest status sequence
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_status
    FIELDS MAX( status_seq )
    WHERE request_id = @iv_request_id
    INTO @lv_max_seq.

  IF lv_max_seq IS INITIAL.

    lv_next_num = 10.

  ELSE.

    lv_next_num = CONV i( lv_max_seq ) + 10.

  ENDIF.

  lv_next_seq =
    |{ lv_next_num WIDTH = 4 PAD = '0' }|.


  "---------------------------------------------------------------
  " STEP 9: Prepare status history
  "---------------------------------------------------------------

  ls_status = VALUE #(
    client      = sy-mandt
    request_id  = iv_request_id
    status_seq  = lv_next_seq
    status      = 'F'
    status_date = sy-datum
    changed_by  = sy-uname
    comments    = 'Request fulfilled successfully'
  ).


  "---------------------------------------------------------------
  " STEP 10: Insert status history
  "---------------------------------------------------------------

  INSERT zesr_status FROM @ls_status.

  IF sy-subrc <> 0.

    ROLLBACK WORK.

    ev_success = abap_false.

    ev_message =
      |Request status history could not be created.|.

    RETURN.

  ENDIF.


  "---------------------------------------------------------------
  " STEP 11: Commit transaction
  "---------------------------------------------------------------

  COMMIT WORK.

  ev_success = abap_true.

  ev_message =
    |Request { iv_request_id } fulfilled successfully.|.

ENDMETHOD.

METHOD get_request_status.

  DATA:
    ls_hdr TYPE zesr_hdr.

  CLEAR:
    ev_success,
    ev_message.

  "---------------------------------------------------------------
  " STEP 1: Read request header
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_hdr
    FIELDS *
    WHERE request_id = @iv_request_id
    INTO @ls_hdr.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request { iv_request_id } does not exist.|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 2: Return current request status
  "---------------------------------------------------------------

  ev_success = abap_true.

  ev_message =
    |Request { iv_request_id } current status: { ls_hdr-status }|.

ENDMETHOD.

METHOD get_request_details.

  DATA:
    ls_hdr  TYPE zesr_hdr,
    ls_item TYPE zesr_item.

  CLEAR:
    ev_success,
    ev_employee_id,
    ev_request_type,
    ev_priority,
    ev_material_id,
    ev_quantity,
    ev_required_date,
    ev_status,
    ev_message.

  "---------------------------------------------------------------
  " STEP 1: Read request header
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_hdr
    FIELDS *
    WHERE request_id = @iv_request_id
    INTO @ls_hdr.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request { iv_request_id } does not exist.|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 2: Read request item
  "---------------------------------------------------------------

  SELECT SINGLE
    FROM zesr_item
    FIELDS *
    WHERE request_id = @iv_request_id
    INTO @ls_item.

  IF sy-subrc <> 0.

    ev_success = abap_false.

    ev_message =
      |Request item for { iv_request_id } does not exist.|.

    RETURN.

  ENDIF.

  "---------------------------------------------------------------
  " STEP 3: Return request details
  "---------------------------------------------------------------

  ev_employee_id   = ls_hdr-employee_id.
  ev_request_type  = ls_hdr-request_type.
  ev_priority      = ls_hdr-priority.
  ev_required_date = ls_hdr-required_date.
  ev_status        = ls_hdr-status.

  ev_material_id   = ls_item-material_id.
  ev_quantity      = ls_item-quantity.

  ev_success = abap_true.

  ev_message =
    |Request { iv_request_id } details retrieved successfully.|.

ENDMETHOD.

ENDCLASS.