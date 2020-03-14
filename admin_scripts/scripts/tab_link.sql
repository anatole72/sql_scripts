REM
REM  Report to list areas that might be affected when making changes
REM  to a table:
REM     - synonyms for specified table
REM     - index listing for specified table
REM     - constraint listing for specified table
REM     - dependency listing for specified table
REM     - foreign key listing for specified table
REM
REM  Developed By TUSC.
REM

PROMPT
PROMPT AREAS AFFECTED MAKING CHANGES TO A TABLE
PROMPT

ACCEPT tab_owner PROMPT "Table owner: "
ACCEPT tab_name  PROMPT "Table name: "

@_BEGIN

REM ***************************************************************************
REM  Synonyms for Specified Table
REM ***************************************************************************

@_WTITLE 'Synonyms for &&tab_owner..&&tab_name'

COLUMN owner            FORMAT A30      HEADING 'Synonym Owner'
COLUMN synonym_name     FORMAT A30      HEADING 'Synonym Name'
COLUMN table_type       FORMAT A6       HEADING 'Type'
COLUMN db_link          FORMAT A40      HEADING 'DB Link'

SELECT
    ds.owner,
    synonym_name,
    SUBSTR(dc.table_type, 1, 1) table_type,
    db_link
FROM
    sys.dba_synonyms ds,
    sys.dba_catalog dc
WHERE
    ds.table_owner = dc.owner
    AND ds.table_name = dc.table_name
    AND ds.table_name = UPPER('&&tab_name')
    AND ds.table_owner = UPPER('&&tab_owner')
;

REM ***************************************************************************
REM  Index Listing for Specified Table
REM ***************************************************************************

@_WTITLE 'Indexes for &&tab_owner..&&tab_name'

COLUMN index_owner          FORMAT A30      HEADING 'Index Owner'
COLUMN index_name           FORMAT A30      HEADING 'Index Name'
COLUMN column_name          FORMAT A30      HEADING 'Column Name'
COLUMN column_position      FORMAT 999      HEADING 'Pos'
COLUMN uniqueness           FORMAT A7       HEADING 'Unique?'

SELECT
    dic.index_owner,
    dic.index_name,
    DECODE(di.uniqueness, 'UNIQUE', 'YES', 'NO') uniqueness,
    dic.column_name,
    dic.column_position
FROM
    sys.dba_indexes di,
    sys.dba_ind_columns dic
WHERE
    dic.table_name = di.table_name
    AND dic.index_owner = di.owner
    AND dic.index_name = di.index_name
    AND dic.table_name = UPPER('&&tab_name')
    AND dic.table_owner = UPPER('&&tab_owner')
ORDER BY
    dic.table_name,
    dic.index_owner,
    di.uniqueness desc,
    dic.index_name,
    dic.column_position
;

REM ***************************************************************************
REM  Constraint Listing for Specified Table
REM ***************************************************************************

@_WTITLE 'Constraints for &&tab_owner..&&tab_name'

COLUMN owner                FORMAT A30      HEADING 'Constraint Owner'
COLUMN constraint_name      FORMAT A30      HEADING 'Constraint Name'
COLUMN search_condition     FORMAT A36      HEADING 'Constraint Text'
COLUMN constraint_type      FORMAT A1       HEADING 'T'
COLUMN column_name          FORMAT A25      HEADING 'On Column'
COLUMN position             FORMAT 999      HEADING 'Pos'

SELECT
    dc.owner,
    dcc.constraint_name,
    dcc.column_name,
    dcc.position,
    dc.constraint_type,
    dc.search_condition
FROM
    sys.dba_constraints dc,
    sys.dba_cons_columns dcc
WHERE
    dcc.table_name = dc.table_name
    AND dcc.owner = dc.owner
    AND dcc.constraint_name = dc.constraint_name
    AND dcc.table_name = UPPER('&&tab_name')
    AND dcc.owner = UPPER('&&tab_owner')
ORDER BY
    dcc.table_name,
    dcc.owner,
    dcc.position,
    dcc.column_name
;

REM ***************************************************************************
REM  Dependency Listing for Specified Table
REM ***************************************************************************

@_WTITLE 'Dependencies for &&tab_owner..&&tab_name'

COLUMN r_name FORMAT A70 HEADING "Referenced By"
COLUMN r_link FORMAT A50 HEADING "Referenced Link"

SELECT
    type || ' ' || owner || '.' || name r_name,
    DECODE(referenced_link_name,
        NULL, 'none',
        referenced_link_name) r_link
FROM
    sys.dba_dependencies
WHERE
    referenced_name = UPPER('&&tab_name')
    AND referenced_owner = UPPER('&&tab_owner')
ORDER BY
    1, 2
;

REM ***************************************************************************
REM  Foreign Key Listing for Specified Table
REM ***************************************************************************

@_WTITLE 'Foreign Keys for &&tab_owner..&&tab_name'

COLUMN owner                    FORMAT A18      HEADING 'Referencing Owner'
COLUMN table_name               FORMAT A30      HEADING 'Referencing Table'
COLUMN column_name              FORMAT A30      HEADING 'Referencing Column'
COLUMN constraint_name          FORMAT A19      HEADING 'Constraint Name'
COLUMN r_column_name            FORMAT A30      HEADING 'Referenced Column'

SELECT
    ca.owner,
    ca.table_name,
    cca.column_name,
    ca.constraint_name,
    ccb.column_name r_column_name
FROM
    sys.dba_constraints ca,
    sys.dba_cons_columns cca,
    sys.dba_constraints cb,
    sys.dba_cons_columns ccb
WHERE
    ca.owner = cca.owner
    AND ca.constraint_name = cca.constraint_name
    AND ca.constraint_type = 'R'
    AND ca.r_owner = cb.owner
    AND ca.r_constraint_name = cb.constraint_name
    AND ca.r_owner = ccb.owner
    AND ca.r_constraint_name = ccb.constraint_name
    AND cca.position = ccb.position
    AND cb.table_name = UPPER('&&tab_name')
    AND cb.owner = UPPER('&&tab_owner')
ORDER BY
    1, 2, 3, cca.position
;

@_END
