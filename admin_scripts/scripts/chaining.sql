REM
REM  Report on the number of CHAINED rows within a named table 
REM
REM  NOTES:  Requires DBA priviledges.
REM          The target table must have a column that is the leading portion
REM             of an index and is defined as not null.
REM          Uses the V$SESSTAT table where USERNAME is the current user.
REM              A problem if > 1 session active with that USERID.
REM          The statistics in V$SESSTAT may change between releases and
REM              platforms.  Make sure that 'table fetch continued row' is
REM              a valid statistic.
REM

@_SET

PROMPT
PROMPT CALCULATES NUMBER OF CHAINED ROWS WITHIN A TABLE
PROMPT
ACCEPT obj_own PROMPT 'Table owner name: '
ACCEPT obj_nam PROMPT 'Table name: '

@_HIDE
SET PAGESIZE 0

REM
REM  Find out what statistic we want
REM
COLUMN statistic# NEW_VALUE stat_no NOPRINT
SELECT statistic# 
FROM v$statname n
WHERE n.name = 'table fetch continued row'
/

REM
REM  Find out who we are in terms of sid
REM
COLUMN sid NEW_VALUE user_sid NOPRINT
SELECT DISTINCT sid 
FROM v$session
WHERE audsid = USERENV('SESSIONID')
/

REM
REM  Find the last col of the table and a not null indexed column
REM
COLUMN column_name  NEW_VALUE last_col          NOPRINT
COLUMN name         NEW_VALUE indexed_column    NOPRINT
COLUMN value        NEW_VALUE before_count      NOPRINT
SELECT column_name
FROM dba_tab_columns
WHERE table_name = UPPER('&&obj_nam')
AND owner = UPPER('&&obj_own')
ORDER BY column_id
/

SELECT 
    c.name
FROM 
    sys.col$ c, 
    sys.obj$ idx, 
    sys.obj$ base, 
    sys.icol$ ic
WHERE 
    base.obj# = c.obj#
    AND ic.bo# = base.obj#
    AND ic.col# = c.col#
    AND base.owner# = (
        SELECT user# 
        FROM sys.user$
	WHERE name = UPPER('&&obj_own')
    )
    AND ic.obj# = idx.obj#
    AND base.name = UPPER('&&obj_nam')
    AND ic.pos# = 1
    AND c.null$ > 0
/

SELECT value
FROM v$sesstat
WHERE v$sesstat.sid = &user_sid
AND v$sesstat.statistic# = &stat_no
/

REM
REM  Select every row from the target table
REM
COLUMN xx NOPRINT
SELECT &last_col xx
FROM &obj_own..&obj_nam
WHERE &indexed_column <= (
    SELECT MAX(&indexed_column)
    FROM &obj_own..&obj_nam
)
/

COLUMN value NEW_VALUE after_count NOPRINT
SELECT value
FROM v$sesstat
WHERE v$sesstat.sid = &user_sid
AND v$sesstat.statistic# = &stat_no
/
 
@_BEGIN
SET HEADING OFF

SELECT 
    'Table ' || UPPER('&obj_own') || '.' || UPPER('&obj_nam') || ' contains '||
    (TO_NUMBER(&after_count) - TO_NUMBER(&before_count)) || ' chained row' ||
    DECODE(TO_NUMBER(&after_count) - TO_NUMBER(&before_count), 1, '.', 's.')
FROM DUAL
WHERE RTRIM('&indexed_column') IS NOT NULL
/

REM
REM  If we don't have an indexed column this won't work so say so
REM
SELECT 
    'Table '|| UPPER('&obj_own') || '.' || UPPER('&obj_nam') ||
    ' has no indexed, not null columns.'
FROM DUAL
WHERE RTRIM('&indexed_column') IS NULL
/

UNDEFINE obj_nam
UNDEFINE obj_own
UNDEFINE before_count
UNDEFINE after_count
UNDEFINE indexed_column
UNDEFINE last_col
UNDEFINE stat_no
UNDEFINE user_sid

@_END
