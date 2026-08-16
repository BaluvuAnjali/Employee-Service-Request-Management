*&---------------------------------------------------------------------*
*& Report zesr_alv_monitor
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zesr_alv_monitor.
TYPES: BEGIN OF ty_output,

         request_id    TYPE zesr_de_reqid,
         employee_id   TYPE zesr_de_emp,
         request_type  TYPE zesr_de_rtype,
         priority      TYPE zesr_de_priority,
         material_id   TYPE char40,
         quantity      TYPE zesr_de_qty,
         status        TYPE zesr_de_status,
         request_date  TYPE dats,
         required_date TYPE dats,

       END OF ty_output.

DATA:
  gt_output TYPE STANDARD TABLE OF ty_output,
  gs_output TYPE ty_output.

START-OF-SELECTION.

  SELECT
    h~request_id,
    h~employee_id,
    h~request_type,
    h~priority,
    i~material_id,
    i~quantity,
    h~status,
    h~request_date,
    h~required_date

    FROM zesr_hdr AS h

    INNER JOIN zesr_item AS i
      ON h~request_id = i~request_id

    INTO TABLE @gt_output.

    IF gt_output IS INITIAL.

    MESSAGE 'No ESR requests found.' TYPE 'I'.

    RETURN.

  ENDIF.