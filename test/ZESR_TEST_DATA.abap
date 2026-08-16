*&---------------------------------------------------------------------*
*& Report zesr_test_data
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_test_data.

DELETE FROM zesr_fullfill
WHERE request_id = '100001'
OR request_id = '100002'
OR request_id = '100003'.

DELETE FROM zesr_status
WHERE request_id = '100001'
OR request_id = '100002'
OR request_id = '100003'.

DELETE FROM zesr_item
WHERE request_id = '100001'
OR request_id = '100002'
OR request_id = '100003'.

DELETE FROM zesr_hdr
WHERE request_id = '100001'
OR request_id = '100002'
OR request_id = '100003'.

"----------------------------------------------------------------------" REQUEST 100001 - ACTIVE REQUEST" Employee E1001 has an active laptop request"----------------------------------------------------------------------

DATA(ls_hdr_1) = VALUE zesr_hdr(
client        = sy-mandt
request_id    = '100001'
employee_id   = 'E1001'
request_type  = 'NEW'
priority      = 'HIGH'
status        = 'PROCESSING'
request_date  = sy-datum
required_date = sy-datum + 5
created_by    = sy-uname
created_on    = sy-datum
).

INSERT zesr_hdr FROM @ls_hdr_1.

DATA(ls_item_1) = VALUE zesr_item(
client       = sy-mandt
request_id   = '100001'
item_no      = '0010'
material_id  = 'LAPTOP-001'
quantity     = 1
reason       = 'New laptop required for project work'
item_status  = 'PROCESSING'
).

INSERT zesr_item FROM @ls_item_1.

" Status history for Request 100001

DATA(ls_status_1) = VALUE zesr_status(
client      = sy-mandt
request_id  = '100001'
status_seq  = '0010'
status      = 'SUBMITTED'
status_date = sy-datum - 2
changed_by  = sy-uname
comments    = 'Request submitted by employee'
).

INSERT zesr_status FROM @ls_status_1.

DATA(ls_status_2) = VALUE zesr_status(
client      = sy-mandt
request_id  = '100001'
status_seq  = '0020'
status      = 'VALIDATED'
status_date = sy-datum - 1
changed_by  = sy-uname
comments    = 'Request validated successfully'
).

INSERT zesr_status FROM @ls_status_2.

DATA(ls_status_3) = VALUE zesr_status(
client      = sy-mandt
request_id  = '100001'
status_seq  = '0030'
status      = 'PROCESSING'
status_date = sy-datum
changed_by  = sy-uname
comments    = 'Request is being processed'
).

INSERT zesr_status FROM @ls_status_3.

"----------------------------------------------------------------------" REQUEST 100002 - FULFILLED REQUEST" Employee E1002 previously received a mouse"----------------------------------------------------------------------

DATA(ls_hdr_2) = VALUE zesr_hdr(
client        = sy-mandt
request_id    = '100002'
employee_id   = 'E1002'
request_type  = 'NEW'
priority      = 'NORMAL'
status        = 'FULFILLED'
request_date  = sy-datum - 10
required_date = sy-datum - 5
created_by    = sy-uname
created_on    = sy-datum - 10
).

INSERT zesr_hdr FROM @ls_hdr_2.

DATA(ls_item_2) = VALUE zesr_item(
client       = sy-mandt
request_id   = '100002'
item_no      = '0010'
material_id  = 'MOUSE-001'
quantity     = 1
reason       = 'Mouse required for office work'
item_status  = 'FULFILLED'
).

INSERT zesr_item FROM @ls_item_2.

" Status history for Request 100002

DATA(ls_status_4) = VALUE zesr_status(
client      = sy-mandt
request_id  = '100002'
status_seq  = '0010'
status      = 'SUBMITTED'
status_date = sy-datum - 10
changed_by  = sy-uname
comments    = 'Request submitted'
).

INSERT zesr_status FROM @ls_status_4.

DATA(ls_status_5) = VALUE zesr_status(
client      = sy-mandt
request_id  = '100002'
status_seq  = '0020'
status      = 'FULFILLED'
status_date = sy-datum - 5
changed_by  = sy-uname
comments    = 'Mouse issued to employee'
).

INSERT zesr_status FROM @ls_status_5.

DATA(ls_fulfill_1) = VALUE zesr_fullfill(
client          = sy-mandt
request_id      = '100002'
item_no         = '0010'
material_id     = 'MOUSE-001'
fulfilled_qty   = 1
fulfill_date    = sy-datum - 5
fulfilled_by    = sy-uname
fulfill_status  = 'FULFILLED').

INSERT zesr_fullfill FROM @ls_fulfill_1.

"----------------------------------------------------------------------" REQUEST 100003 - SUBMITTED REQUEST" Employee E1003 has another active request"----------------------------------------------------------------------

DATA(ls_hdr_3) = VALUE zesr_hdr(
client        = sy-mandt
request_id    = '100003'
employee_id   = 'E1003'
request_type  = 'REPLACEMENT'
priority      = 'NORMAL'
status        = 'SUBMITTED'
request_date  = sy-datum
required_date = sy-datum + 7
created_by    = sy-uname
created_on    = sy-datum
).

INSERT zesr_hdr FROM @ls_hdr_3.

DATA(ls_item_3) = VALUE zesr_item(
client       = sy-mandt
request_id   = '100003'
item_no      = '0010'
material_id  = 'KEYBOARD-001'
quantity     = 1
reason       = 'Existing keyboard needs replacement'
item_status  = 'SUBMITTED'
).

INSERT zesr_item FROM @ls_item_3.

DATA(ls_status_6) = VALUE zesr_status(
client      = sy-mandt
request_id  = '100003'
status_seq  = '0010'
status      = 'SUBMITTED'
status_date = sy-datum
changed_by  = sy-uname
comments    = 'Replacement request submitted'
).

INSERT zesr_status FROM @ls_status_6.

"----------------------------------------------------------------------" Commit all changes"----------------------------------------------------------------------

COMMIT WORK.

WRITE: / 'ESR test data created successfully.'.
WRITE: / '----------------------------------------'.
WRITE: / 'Request 100001 - E1001 - LAPTOP-001 - PROCESSING'.
WRITE: / 'Request 100002 - E1002 - MOUSE-001 - FULFILLED'.
WRITE: / 'Request 100003 - E1003 - KEYBOARD-001 - SUBMITTED'.