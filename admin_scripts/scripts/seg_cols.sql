REM
REM  This script allows you to determine the SEGMENT order of columns
REM  in a table. This may be required to see if, for example, a 'LONG'
REM  is the last column in the table segment.
REM 
REM  The script must be run as SYS.
REM

PROMPT
PROMPT PHYSICAL ORDER OF COLUMNS IN A TABLE
PROMPT
PROMPT The script must be run as SYS!

@_CONFIRM "continue"
PROMPT

ACCEPT us_name PROMPT "Table owner: "
ACCEPT tb_name PROMPT "Table name: "

@_BEGIN
@_TITLE "Order of columns in the &us_name..&tb_name"

SELECT  
    c.col# 	    "Describe Order",
    c.segcol# 	"Segment Order",
    c.name 	    "Column Name",
    c.type# 	"ColType"
FROM 
    col$ c, 
    obj$ o, 
    user$ u
WHERE 
    c.obj# = o.obj#
    AND o.owner# = u.user#
    AND u.name = UPPER('&us_name')
    AND o.name = UPPER('&tb_name')
ORDER BY 
    segcol#
;
UNDEFINE us_name tb_name
@_END

