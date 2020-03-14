REM
REM  Prints free space map (free extents) for tablespaces in a database
REM

PROMPT
PROMPT FREE SPACE MAP
PROMPT
ACCEPT ts PROMPT "Tablespace name like (ENTER for all): "

@_BEGIN
@_TITLE "TABLESPACE FREE SPACE MAP"

BREAK ON tablespace_name SKIP 2 
COMPUTE SUM OF kbytes ON tablespace_name

SELECT
    tablespace_name,
    file_id, 
    block_id, 
    blocks,
    bytes / 1024 kbytes 
FROM 
    dba_free_space
WHERE
    tablespace_name LIKE NVL(UPPER('&&ts'), '%')
ORDER BY
    tablespace_name, file_id, block_id
;

@_END
