REM
REM  Display database files
REM

@_SET

PROMPT
PROMPT D A T A F I L E S
PROMPT
ACCEPT fn PROMPT "File name like (ENTER for all): "
ACCEPT ts PROMPT "Tablespace name like (ENTER for all): "
ACCEPT st PROMPT "File status like (ENTER for all): "
ACCEPT by PROMPT "Order by ((N)ame, (T)ablespace, (S)ize, ENTER for ID): " 

@_BEGIN
@_WTITLE "DATABASE FILES"

COLUMN file_id          FORMAT 990 HEADING "F#"
COLUMN file_name        FORMAT A50 WRAP
COLUMN tablespace_name  FORMAT A30 WRAP
COLUMN mbytes           FORMAT 999,990 HEADING "MBYTES"
COLUMN maxext           FORMAT 9,990 HEADING "MAXEXT"
COLUMN next             FORMAT 990 HEADING "NEXT"
COLUMN status           FORMAT A9

SELECT
    file_id,
    file_name,
    tablespace_name,
    bytes / (1024 * 1024) mbytes,
    maxextend / (1024 * 1024) maxext,
    inc / (1024 * 1024) next,
    status
FROM
    sys.dba_data_files f,
    sys.filext$ x
WHERE
    file_name LIKE NVL('&&fn', '%')
    AND tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND status LIKE NVL(UPPER('&&st'), '%')
    AND file_id = x.file#(+)
ORDER BY
    DECODE(UPPER('&&by'),
        'N', file_name,
        'T', tablespace_name,
        'S', TO_CHAR(bytes, '00000000000000'),
        TO_CHAR(file_id, '00000')
    )
;

UNDEFINE fn ts st by

@_END

