rem 
rem  List segment extents
rem

@_SET
SET HEADING OFF
SET PAGESIZE 0

PROMPT
PROMPT S E G M E N T   E X T E N T S
PROMPT

ACCEPT own PROMPT "Segment owner like (ENTER for all): "
ACCEPT nam PROMPT "Segment name like (ENTER for all): "
PROMPT

PROMPT Allowable segment types:
SELECT DISTINCT segment_type
FROM dba_extents
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
ORDER BY segment_type;

PROMPT
ACCEPT typ  PROMPT "Segment type like (ENTER for all): "
PROMPT

PROMPT Allowable tablespaces:
SELECT DISTINCT tablespace_name
FROM dba_extents
WHERE
    owner LIKE NVL(UPPER('&&own'), '%')
    AND segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND segment_type LIKE NVL(UPPER('&&typ'), '%')
ORDER BY tablespace_name;

PROMPT
ACCEPT ts  PROMPT "Tablespace name like (ENTER for all): "
ACCEPT siz PROMPT "Min extent size (ENTER for 0 blocks): " NUMBER

@_BEGIN
@_WTITLE "S E G M E N T   E X T E N T S"

COLUMN owner            FORMAT A25 
COLUMN sname            FORMAT A30 HEADING 'SEGMENT_NAME'
COLUMN segment_type     FORMAT A8  HEADING 'TYPE'
COLUMN tablespace_name  FORMAT A25 
COLUMN block_id         FORMAT 999,990
COLUMN blocks           FORMAT 999,990
COLUMN bytes            FORMAT 999,999,990
COLUMN extent_id        FORMAT 999 HEADING 'EXT_ID'
COLUMN contig           FORMAT A1

SELECT
    e.owner,
    e.segment_name sname, 
    e.segment_type, 
    e.tablespace_name,
    e.block_id,
    e.blocks,
    e.bytes,
    e.extent_id,
    DECODE(ec.blocks, NULL, ' ', 'Y') contig
FROM
    sys.dba_extents e,
    sys.dba_extents ec
WHERE
    e.owner LIKE NVL(UPPER('&&own'), '%')
    AND e.segment_name LIKE NVL(UPPER('&&nam'), '%')
    AND e.segment_type LIKE NVL(UPPER('&&typ'), '%')
    AND e.tablespace_name LIKE NVL(UPPER('&&ts'), '%')
    AND e.blocks >= TO_NUMBER(&&siz)
    AND e.owner = ec.owner(+)
    AND e.segment_name = ec.segment_name(+)
    AND e.tablespace_name = ec.tablespace_name(+) 
    AND e.file_id = ec.file_id(+)
    AND e.extent_id = ec.extent_id(+) + 1
    AND e.block_id = ec.block_id(+) + ec.blocks(+)
ORDER BY
    e.owner,
    e.segment_name,
    e.extent_id
;

UNDEFINE own nam typ ts siz

@_END

