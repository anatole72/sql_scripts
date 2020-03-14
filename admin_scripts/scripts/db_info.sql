REM
REM *** DATABASE INFORMATION REPORT ***
REM
REM Created by:     Mark D. Scull, Oracle Premium Support
REM On:             June 19, 1996
REM Last Modified:  May 22, 1997
REM

@_BEGIN

@_WTITLE "DATABASE INFORMATION"

SELECT created, log_mode FROM v$database
/


@_WTITLE "INIT PARAMETERS INFO"

COLUMN "PARAMETER NAME"     FORMAT A45
COLUMN type                 FORMAT 99999
COLUMN value                FORMAT A70
COLUMN num                  FORMAT 99999

SELECT
    num,
    name "PARAMETER NAME",
    value,
    type
FROM
    v$parameter
ORDER BY
    name
/


@_WTITLE "TABLESPACE INFORMATION"

BREAK ON "Tablespace Name" SKIP 1

SELECT
    SUBSTR(ts.tablespace_name, 1, 30) "Tablespace Name",
    SUBSTR(ts.initial_extent, 1, 10) "Initial",
    SUBSTR(ts.next_extent, 1, 10) "Next",
    SUBSTR(ts.min_extents, 1, 5) "MinEx",
    SUBSTR(ts.max_extents, 1, 5) "MaxEx",
    SUBSTR(ts.pct_increase, 1, 5) "%Incr",
    SUBSTR(ts.status, 1, 8) "Status",
    SUBSTR(df.file_name, 1, 50) "DataFile Assigned"
FROM
    sys.dba_tablespaces ts,
    sys.dba_data_files df
WHERE
    ts.tablespace_name = df.tablespace_name(+)
    AND ts.status NOT LIKE 'INVALID'
ORDER BY
    ts.tablespace_name,
    df.file_name
/


@_WTITLE "TABLESPACE USAGE INFORMATION"

COLUMN "Total Bytes"    FORMAT 9,999,999,999,999
COLUMN "Oracle Blocks"  FORMAT 9,999,999,999
COLUMN "Bytes Free"     FORMAT 9,999,999,999,999
COLUMN "Bytes Used"     FORMAT 9,999,999,999,999
COLUMN "% Free"         FORMAT 9999.999
COLUMN "% Used"         FORMAT 9999.999

CLEAR BREAKS
CLEAR COMPUTES

BREAK ON REPORT
COMPUTE SUM OF "Total Bytes"    ON REPORT
COMPUTE SUM OF "Oracle Blocks"  ON REPORT
COMPUTE SUM OF "Bytes Free"     ON REPORT
COMPUTE SUM OF "Bytes Used"     ON REPORT
COMPUTE AVG OF "% Free"         ON REPORT
COMPUTE AVG OF "% Used"         ON REPORT

SELECT
    SUBSTR(fs.file_id, 1, 3) "Id#",
    fs.tablespace_name "Tablespace Name",
    df.bytes "Total Bytes",
    df.blocks "Oracle Blocks",
    SUM(fs.bytes) "Bytes Free",
    (100 * ((SUM(fs.bytes)) / df.bytes)) "% Free",
    df.bytes - SUM(fs.bytes) "Bytes Used",
    (100 * ((df.bytes - SUM(fs.bytes)) / df.bytes)) "% Used"
FROM
    sys.dba_data_files df,
    sys.dba_free_space fs
WHERE
    df.file_id(+) = fs.file_id
GROUP BY
    fs.file_id,
    fs.tablespace_name,
    df.bytes,
    df.blocks
ORDER BY
    fs.tablespace_name
/


@_WTITLE "DATAFILES INFORMATION"

COLUMN "Bytes"          FORMAT 9,999,999,999,999
COLUMN "Oracle Blocks"  FORMAT 9,999,999,999

CLEAR BREAKS
CLEAR COMPUTES

BREAK ON REPORT
COMPUTE SUM OF bytes "Bytes"            ON REPORT
COMPUTE SUM OF blocks "Oracle Blocks"   ON REPORT

SELECT
    SUBSTR(file_id, 1, 3) "Id#",
    SUBSTR(file_name, 1, 52) "DataFile Name",
    SUBSTR(tablespace_name, 1, 25) "Related Tablespace",
    bytes "Bytes",
    blocks "Oracle Blocks",
    status "Status"
FROM
    sys.dba_data_files
ORDER BY
    tablespace_name, file_name
/

CLEAR BREAKS
CLEAR COMPUTES


@_WTITLE "ROLLBACKS INFORMATION"

SELECT
    SUBSTR(sys.dba_rollback_segs.segment_id, 1, 5) "Id#",
    SUBSTR(sys.dba_segments.owner, 1, 8) "Owner",
    SUBSTR(sys.dba_segments.tablespace_name, 1, 17) "Tablespace Name",
    SUBSTR(sys.dba_segments.segment_name, 1, 17) "Rollback Name",
    SUBSTR(sys.dba_rollback_segs.initial_extent, 1, 10) "Initial",
    SUBSTR(sys.dba_rollback_segs.next_extent, 1, 10) "Next",
    SUBSTR(sys.dba_segments.min_extents, 1, 5) "MinEx",
    SUBSTR(sys.dba_segments.max_extents, 1, 5) "MaxEx",
    SUBSTR(sys.dba_segments.pct_increase, 1, 5) "%Incr",
    SUBSTR(sys.dba_segments.bytes, 1, 15) "Size (Bytes)",
    SUBSTR(sys.dba_segments.extents, 1, 7) "Extents",
    SUBSTR(sys.dba_rollback_segs.status, 1, 10) "Status"
FROM
    sys.dba_segments,
    sys.dba_rollback_segs
WHERE
    sys.dba_segments.segment_name = sys.dba_rollback_segs.segment_name
    AND sys.dba_segments.segment_type = 'ROLLBACK'
ORDER BY
    sys.dba_rollback_segs.segment_id
/


@_WTITLE "TABLES INFORMATION"

COLUMN "Owner"                  FORMAT A15
COLUMN "Tablespace Name"        FORMAT A28
COLUMN "Table Name"             FORMAT A30

BREAK ON "Owner" SKIP 1

SELECT
    owner "Owner",
    tablespace_name "Tablespace Name",
    table_name "Table Name",
    SUBSTR(pct_free, 1, 3) "%F",
    SUBSTR(pct_used, 1, 3) "%U",
    SUBSTR(ini_trans, 1, 2) "IT",
    SUBSTR(max_trans, 1, 3) "MTr",
    SUBSTR(initial_extent, 1, 10) "Initial",
    SUBSTR(next_extent, 1, 10) "Next",
    SUBSTR(min_extents, 1, 5) "MinEx",
    SUBSTR(max_extents, 1, 5) "MaxEx",
    SUBSTR(pct_increase, 1, 5) "%Incr"
FROM
    sys.dba_tables
ORDER BY
    owner,
    tablespace_name,
    table_name
/

CLEAR BREAKS
CLEAR COMPUTES


@_WTITLE "INDEXES INFORMATION"

BREAK ON table_name ON REPORT

SELECT  DISTINCT
    table_name,
    index_name,
    status,
    uniqueness
FROM
    sys.dba_indexes
WHERE
    table_owner NOT IN ('SYS', 'SYSTEM')
    AND table_type = 'TABLE'
ORDER BY
    table_name,
    index_name
/


@_WTITLE "SYNONYMS INFORMATION"

CLEAR BREAKS
CLEAR COMPUTES

BREAK ON "owner" SKIP 1

SELECT
    SUBSTR(owner, 1, 15) owner,
    synonym_name,
    SUBSTR(table_owner, 1, 15) table_owner,
    SUBSTR(table_name, 1, 30) table_name,
    SUBSTR(db_link, 1, 20) db_link
FROM
    sys.dba_synonyms
WHERE
    owner NOT IN ('SYS', 'SYSTEM')
    AND table_owner NOT IN ('SYS', 'SYSTEM')
ORDER BY
    owner,
    synonym_name,
    table_name
/


@_WTITLE "VIEWS INFORMATION"

CLEAR BREAKS
CLEAR COMPUTES
CLEAR COLUMNS

BREAK ON table_name ON "VIEW NAME" SKIP 1

SELECT DISTINCT
    v.view_name "VIEW NAME",
    c.table_name,
    c.column_name,
    c.data_type,
    c.data_length
FROM
    sys.dba_views v,
    sys.dba_tab_columns c
WHERE
    v.view_name = c.table_name
    AND v.owner NOT IN ('SYS', 'SYSTEM')
ORDER BY
    v.view_name, c.column_name
/


@_WTITLE "OTHER OBJECTS INFORMATION"

CLEAR BREAKS
CLEAR COMPUTES

BREAK ON "owner" SKIP 1

SELECT
    owner,
    SUBSTR(object_name, 1, 30) object_name,
    object_type,
    status,
    created
FROM
    sys.dba_objects
WHERE
    object_type NOT IN ('INDEX', 'SYNONYM', 'TABLE', 'VIEW')
    AND owner NOT IN ('SYS', 'SYSTEM')
ORDER BY
    owner,
    object_type
/


@_WTITLE "USERS INFORMATION"

SELECT
    user_id,
    SUBSTR(username, 1, 30) UserName,
    SUBSTR(password, 1, 16) Password,
    SUBSTR(default_tablespace, 1, 25) "Default TBS",
    SUBSTR(temporary_tablespace, 1, 25) "Temporary TBS",
    created,
    SUBSTR(profile, 1, 10) Profile
FROM
    sys.dba_users
ORDER BY
    username
/

@_END
