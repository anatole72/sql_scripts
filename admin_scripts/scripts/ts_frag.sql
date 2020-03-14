REM
REM  The following is a script that will determine how many extents
REM  of contiguous free space you have in Oracle as well as the
REM  total amount of free space you have in each tablespace. From
REM  these results you can detect how fragmented your tablespace is.
REM
REM  The ideal situation is to have one large free extent in your
REM  tablespace. The more extents of free space there are in the
REM  tablespace, the more likely you  will run into fragmentation
REM  problems. The size of the free extents is also  very important.
REM  If you have a lot of small extents (too small for any next
REM  extent size) but the total bytes of free space is large, then
REM  you may want to consider defragmentation options.
REM

@_SET
@_HIDE
SET PAGESIZE 0

CREATE TABLE temp$space (
   tablespace_name   CHAR(30),
   contiguous_bytes  NUMBER
)
/

DECLARE
    CURSOR query IS 
        SELECT *
        FROM dba_free_space
        ORDER BY tablespace_name, block_id;

    this_row      query%ROWTYPE;
    previous_row  query%ROWTYPE;
    total         NUMBER;

BEGIN
    OPEN query;
    FETCH query INTO this_row;
    previous_row := this_row;
    total := previous_row.bytes;
    LOOP
        FETCH query INTO this_row;
        EXIT WHEN query%NOTFOUND;
        IF this_row.block_id = previous_row.block_id + previous_row.blocks THEN
            total := total + previous_row.bytes;
            INSERT INTO temp$space (tablespace_name)
                VALUES (previous_row.tablespace_name);
        ELSE
            INSERT INTO temp$space 
                VALUES (previous_row.tablespace_name, total);
            total := this_row.bytes;
        END IF;
        previous_row := this_row;
    END LOOP;
    INSERT INTO temp$space 
        VALUES (previous_row.tablespace_name, total);
END;
.
/

@_BEGIN
@_TITLE 'CONTIGUOUS FREE SPACE REPORT'

COLUMN "CONTIGUOUS BYTES"       FORMAT 999,999,999
COLUMN "COUNT"                  FORMAT 999
COLUMN "TOTAL BYTES"            FORMAT 999,999,999

BREAK ON "TABLESPACE NAME" SKIP 1
COMPUTE SUM OF "CONTIGUOUS BYTES" ON "TABLESPACE NAME" 

SELECT 
    tablespace_name  "TABLESPACE NAME",
    contiguous_bytes "CONTIGUOUS BYTES"
FROM 
    temp$space
WHERE 
    contiguous_bytes IS NOT NULL
ORDER BY 
    tablespace_name, 
    contiguous_bytes DESC
;

@_HIDE
DROP TABLE temp$space
/
@_SET
@_END

