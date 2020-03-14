PROMPT
PROMPT TABLES AND THEIR INDEXES SIZE
PROMPT

ACCEPT own PROMPT "Table owner like (ENTER for all): "
ACCEPT nam PROMPT "Table name like (ENTER for all): "

@_HIDE
COLUMN value NOPRINT NEW_VALUE blk_size
SELECT value 
FROM v$parameter
WHERE name = 'db_block_size';

@_BEGIN
@_TITLE "TABLES AND THEIR INDEXES SIZE"

COLUMN ow FORMAT A18            HEADING 'Owner' 
COLUMN ty FORMAT A7             HEADING 'Type'
COLUMN na FORMAT A39            HEADING 'Name'
COLUMN sz FORMAT 999,999,999    HEADING 'Size (K)'

BREAK ON ow SKIP 1
COMPUTE SUM LABEL Total OF sz ON ow

SELECT
    us.name ow,
    'Table' ty,
    obj.name na,
    seg.blocks * &&blk_size / 1024 sz
FROM
    sys.user$ us,
    sys.obj$  obj,
    sys.seg$  seg,
    sys.tab$  tab
WHERE
    us.name LIKE NVL(UPPER('&&own'), '%')
    AND us.user# = seg.user#
    AND obj.obj# = tab.obj#
    AND tab.file# = seg.file#
    AND tab.block# = seg.block#
    AND tab.clu# IS NULL
    AND obj.name LIKE NVL(UPPER('&&nam'), '%')
UNION
SELECT
    us.name ow,
    '  Index' ty,
    tab.name || '/' || obj.name na1,
    seg.blocks * &&blk_size / 1024 sz
FROM
    sys.user$ us,
    sys.obj$  obj,
    sys.obj$  tab,
    sys.seg$  seg,
    sys.ind$  ind
WHERE
    us.name LIKE NVL(UPPER('&&own'), '%')
    AND us.user# = seg.user#
    AND obj.obj# = ind.obj#
    AND ind.bo# = tab.obj#
    AND ind.file# = seg.file#
    AND ind.block# = seg.block#
    AND tab.name LIKE NVL(UPPER('&&nam'), '%')
ORDER BY
    1, 3
/

UNDEFINE own nam

@_END
