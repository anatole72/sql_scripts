REM
REM  Document control file location and status
REM  MRA 6/16/97 
REM

@_BEGIN
@_TITLE "Control files"

COLUMN num      FORMAT 99   HEADING '#'
COLUMN name     FORMAT a60  HEADING 'Location' WORD_WRAPPED
COLUMN status   FORMAT a7   HEADING 'Status'

SELECT 
    rownum num,
    name, 
    status 
FROM 
    v$controlfile
;
@_END
