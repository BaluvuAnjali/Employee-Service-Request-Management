*&---------------------------------------------------------------------*
*& Report zesr_test_item_insert
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_test_item_insert.
DATA ls_item TYPE zesr_item.

ls_item = VALUE #(
  client      = sy-mandt
  request_id  = '100004'
  item_no     = '0010'
  material_id = 'MONITOR-001'
  quantity    = '1'
  reason      = 'New monitor required'
  item_status = 'S'
).

INSERT zesr_item FROM @ls_item.

WRITE: / 'SY-SUBRC =', sy-subrc.

IF sy-subrc = 0.
  COMMIT WORK.
  WRITE: / 'ITEM INSERTED SUCCESSFULLY'.
ELSE.
  WRITE: / 'ITEM INSERT FAILED'.
ENDIF.