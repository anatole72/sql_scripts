REM
REM  Find segment information having file# and block#. Is used for
REM  identifying corrupted segments and extents.
REM

PROMPT
PROMPT W H A T   S E G M E N T ?
PROMPT

ACCEPT file PROMPT "File number: "
ACCEPT block PROMPT "Block number: "

@_BEGIN
@_TITLE "Datafile &&file, block &&block"
SET HEADING OFF

SELECT
    'Datafile name:        ' || f.file_name nl,
    'Segment owner:        ' || e.owner nl,
    'Segment name:         ' || e.segment_name nl,
    'Segment type:         ' || e.segment_type nl,
    'Tablespace name:      ' || e.tablespace_name nl,
    'Extent number:        ' || e.extent_id nl,
    'Extent start block:   ' || e.block_id nl,
    'Extent size (blocks): ' || e.blocks nl
FROM
    dba_extents e,
    dba_data_files f
WHERE
    e.file_id = TO_NUMBER(&&file)
    AND e.file_id = f.file_id
    AND TO_NUMBER(&&block) BETWEEN e.block_id AND e.block_id + e.blocks - 1
;

UNDEFINE file block
@_END
