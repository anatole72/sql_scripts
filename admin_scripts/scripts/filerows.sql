REM
REM  Report a table's rows per datafile (striping effectiveness)
REM

PROMPT
PROMPT TABLE'S ROWS PER DATAFILE
PROMPT
ACCEPT tabowner PROMPT "Table owner: "
ACCEPT tabname  PROMPT "Table name: "

@_BEGIN
@_TITLE '&tabowner..&tabname' 
 
COLUMN fileid   FORMAT 99999        HEADING 'File ID'
COLUMN filen    FORMAT A58          HEADING 'File Name'
COLUMN nrows    FORMAT 999,999,999  HEADING 'Row Count' 
 
SELECT 
    DECODE(SUBSTR(t.rowid, 18, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) + 
    DECODE(SUBSTR(t.rowid, 17, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 + 
    DECODE(SUBSTR(t.rowid, 16, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 * 16 + 
    DECODE(SUBSTR(t.rowid, 15, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 * 16 * 16 fileid,
    f.file_name filen,
    COUNT(t.rowid) nrows 
FROM 
    &tabowner..&tabname t,
    dba_data_files f
WHERE
    DECODE(SUBSTR(t.rowid, 18, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) + 
    DECODE(SUBSTR(t.rowid, 17, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 + 
    DECODE(SUBSTR(t.rowid, 16, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 * 16 + 
    DECODE(SUBSTR(t.rowid, 15, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 * 16 * 16
    = f.file_id
GROUP BY
    DECODE(SUBSTR(t.rowid, 18, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) + 
    DECODE(SUBSTR(t.rowid, 17, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 + 
    DECODE(SUBSTR(t.rowid, 16, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 * 16 + 
    DECODE(SUBSTR(t.rowid, 15, 1),
        '0', 0,  '1', 1,  '2', 2,  '3', 3,
        '4', 4,  '5', 5,  '6', 6,  '7', 7,
        '8', 8,  '9', 9,  'A', 10, 'B', 11,
        'C', 12, 'D', 13, 'E', 14, 'F', 15) * 16 * 16 * 16,
    f.file_name
/ 
 
UNDEFINE tabowner 
UNDEFINE tabname

@_END
