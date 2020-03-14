REM
REM  Script to determine INDEX storage requirement
REM
REM  DESCRIPTION:
REM
REM  The following formula and associated sample demonstrate a method of
REM  determining index storage size requirements on a fully populated table.
REM 
REM  METHOD:
REM 
REM  A commonly used formula that I've seen used and that generally errors on
REM  the conservative side is detailed below. This formula returns the index size
REM  in DB blocks. Also, this formula is only valid if the CREATE INDEX is issued
REM  on a fully populated table. Precreating the index on an empty table and
REM  subsequently populating the table will require storage requirements greater
REM  than these calulations.
REM 
REM  Formula:
REM 
REM  greatest (4, (1.05) *
REM    (( row_count /
REM      ((
REM        floor (
REM          (( db_block_size - 113 - ( initrans * 23 )) * (1 - (percent_free / 100 ))) /
REM          (( 10 + uniqueness ) + number_col_index + ( total_col_length ))
REM        )
REM      ))
REM    ) * 2 )
REM  )
REM 
REM  LEGEND:
REM 
REM  row_count        => Estimated number of rows in the table
REM  Value: select count(*) from tab_name
REM  
REM  db_block_size    => Actual number of bytes available in the block
REM  Value: select to_number(value) from v$parameter where name = 'db_block_size'
REM 
REM  initrans         => Bytes used for each initrans
REM  Value: The default for indexes is 2 (see INITRANS parameter of CREATE INDEX)
REM  Note:  In 7.2 and higher may be better to multiply this value by 24 rather than 23
REM 
REM  percent_free     => Percent free specified for the index
REM  Value: The default for indexes is 10 (see PCTFREE parameter of CREATE INDEX)
REM 
REM  uniqueness       => If the index is unique or not (1 for unique, 0 for not unique)
REM  Value: Self-explanatory, will you having repeating values or not
REM 
REM  number_col_index => Number of columns in the index
REM  Value: Self-explanatory, how many columns will be in the index key
REM 
REM  total_col_length => Estimated length of the index columns
REM  Value: select avg(nvl(vsize(col_name1),0))+avg(nvl(vsize(col_name2),0)) from tab_name
REM 

@_BEGIN

PROMPT
PROMPT ESTIMATE THE SIZE OF AN INDEX 
PROMPT

ACCEPT tab      PROMPT "Indexed table (OWNER.TABLE): "
ACCEPT ncol     PROMPT "How many columns will be indexed? (<=4): "    NUMBER
ACCEPT col1     PROMPT "First indexed column: "
ACCEPT col2     PROMPT "Second indexed column ('' if none): "
ACCEPT col3     PROMPT "Third indexed column ('' if none): "
ACCEPT col4     PROMPT "Fourth indexed column ('' if none): "
ACCEPT uniq     PROMPT "Index uniqueness (1 for unique, 0 for nonunique): " NUMBER
ACCEPT intr     PROMPT "Index INITRANS (ENTER for default 2): "
ACCEPT pctf     PROMPT "Index PCT_FREE (ENTER for default 10): "

SET SERVEROUTPUT ON

DECLARE

    row_count           NUMBER;
    db_block_size       NUMBER;
    total_col_length    NUMBER;
    size_in_blocks      NUMBER;

BEGIN

    SELECT COUNT(*) INTO row_count FROM &&tab;
    
    SELECT TO_NUMBER(value)
    INTO db_block_size
    FROM v$parameter WHERE name = 'db_block_size';

    SELECT
        AVG(NVL(VSIZE(&&col1), 0)) +
        AVG(NVL(VSIZE(&&col2), 0)) +
        AVG(NVL(VSIZE(&&col3), 0)) +
        AVG(NVL(VSIZE(&&col4), 0))
    INTO total_col_length
    FROM &&tab;

    SELECT GREATEST (4, (1.05) *
      (( row_count /
        ((
          FLOOR (
            (( db_block_size - 113 - ( TO_NUMBER(NVL('&&intr', '2')) * 23 )) *
                (1 - (TO_NUMBER(NVL('&&pctf', '10')) / 100 ))) /
            (( 10 + &&uniq ) + &&ncol + ( total_col_length ))
          )
        ))
      ) * 2 )
    )
    INTO size_in_blocks
    FROM sys.dual;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    DBMS_OUTPUT.PUT_LINE('ESTIMATED SIZE IN BLOCKS: ' || ROUND(size_in_blocks));
    DBMS_OUTPUT.PUT_LINE('-----------------------------------');

END;
/

UNDEFINE tab ncol col1 col2 col3 col4 uniq intr pctf

@_END
