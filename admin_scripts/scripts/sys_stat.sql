REM
REM  Do a quick query of all ORACLE System Statistics
REM

PROMPT
PROMPT SYSTEM STATISTICS
PROMPT

ACCEPT nam PROMPT "Statistic name like (ENTER for all): "
PROMPT Statistics classes ([U]ser, [R]edo, [E]nqueue, [C]ache, [O]PS,
ACCEPT cls PROMPT "Cache[/]OPS, [S]QL, [I]nternal, ENTER for all): "
ACCEPT nul PROMPT "Show zero values (Y/(N)): "

@_BEGIN
@_TITLE "System Statistics"

COLUMN name     HEADING 'Statistic Name'    FORMAT A56
COLUMN type     HEADING 'Class'             FORMAT A10
COLUMN value    HEADING 'Value'             FORMAT 9999999999

BREAK ON type SKIP 1

SELECT
    DECODE(class,
    	1,   'User',
	    2,   'Redo',
	    4,   'Enqueue',
	    8,   'Cache',
	    32,  'OPS',
	    40,  'Cache/OPS',
	    64,  'SQL',
	    128, 'Internal',
	    'Unknown') type,
	RPAD(name, 56, '.') name, 
	value
FROM 
	v$sysstat
WHERE
    UPPER(name) LIKE NVL(UPPER('&&nam'), '%')
    AND value > DECODE(UPPER('&&nul'), 'Y', -1, 0)
    AND INSTR(NVL(UPPER('&&cls'), 'URECO/SIU'),
        DECODE(class,
    	1,   'U', -- User
	    2,   'R', -- Redo
	    4,   'E', -- Enqueue
	    8,   'C', -- Cache
	    32,  'O', -- OPS
	    40,  '/', -- Cache/OPS
	    64,  'S', -- SQL
	    128, 'I', -- Internal 
	    'U')) <> 0 
ORDER BY 
	type, 
	name
/

UNDEFINE nam nul cls
@_END

