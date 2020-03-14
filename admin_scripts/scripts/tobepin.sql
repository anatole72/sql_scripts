REM
REM  List the PL/SQL packages that can be pinned, in order.
REM

@_BEGIN
@_TITLE "PL/SQL PACKAGES CAN BE PINNED"

SELECT
   owner, 
   name package, 
   source_size + code_size + parsed_size + error_size total_bytes
FROM
   dba_object_size
WHERE
   type = 'PACKAGE BODY'
ORDER BY
   3 DESC
;

@_END
