REM
REM  Generate a report on sequences
REM

PROMPT
PROMPT LIST SEQUENCES
PROMPT

ACCEPT seq_owner PROMPT 'Owner name like (ENTER for all): '
ACCEPT seq_name  PROMPT 'Sequence name like (ENTER for all): '

@_BEGIN 
@_WTITLE "SEQUENCES REPORT"

COLUMN sequence_owner   FORMAT A30	    HEADING 'Sequence Owner'
COLUMN sequence_name	FORMAT A30	    HEADING 'Sequence Name'
COLUMN min_value                        HEADING 'Minimum'
COLUMN max_value                        HEADING 'Maximum'
COLUMN increment_by	    FORMAT 9999	    HEADING 'Incrm'
COLUMN cycle_flag       FORMAT A5	    HEADING 'Cycle'
COLUMN order_flag       FORMAT A5	    HEADING 'Order'
COLUMN cache_size	    FORMAT 99999	HEADING 'Cache'
COLUMN last_number                      HEADING 'Last Value'
BREAK ON sequence_owner SKIP 1

SELECT  
    sequence_owner, 
    sequence_name, 
    min_value, 
    max_value,
    increment_by, 
    DECODE(cycle_flag, 'Y', 'YES', 'N', 'NO') cycle_flag,
    DECODE(order_flag, 'Y', 'YES', 'N', 'NO') order_flag,
    cache_size, 
    last_number
FROM 	
    dba_sequences
WHERE  
    sequence_owner LIKE NVL(UPPER('&seq_owner'), '%') 
    AND	sequence_name LIKE NVL(UPPER('&seq_name'), '%')
ORDER BY  
    sequence_owner, 
    sequence_name
;

UNDEFINE seq_owner seq_name
@_END                                                                                                                    
