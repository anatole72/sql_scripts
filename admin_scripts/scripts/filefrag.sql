REM
REM  Free space fragmentation in datafiles
REM

@_BEGIN
@_WTITLE "Datafiles Free Space Fragmentation"

COLUMN tablespace_name FORMAT A30          HEADING 'Tablespace Name'
COLUMN file_name       FORMAT A61          HEADING 'Datafile Name'
COLUMN file_id         FORMAT 999          HEADING 'File'
COLUMN block_id        FORMAT 9999999      HEADING 'Start Block'
COLUMN blocks          FORMAT 9999999      HEADING 'Blocks'
COLUMN kbytes          FORMAT 999,999,999  HEADING 'KBytes'

BREAK ON file_id ON tablespace_name ON file_name SKIP 1
COMPUTE SUM OF kbytes ON file_name

SELECT
    fs.file_id,
    df.file_name,
    fs.tablespace_name,
    fs.block_id,
    fs.blocks,
    fs.bytes / 1024 kbytes
FROM
    sys.dba_free_space fs,
    sys.dba_data_files df
WHERE
    df.file_id = fs.file_id
ORDER BY
    fs.file_id,
    fs.tablespace_name,
    fs.block_id
;
@_END
