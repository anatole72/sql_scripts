REM
REM  Examine statistics in the X$KCBCBH table with intent 
REM  to shrink the SGA.
REM 

@_BEGIN

PROMPT 
PROMPT REMOVING UNNECESSARY BUFFERS
PROMPT 
PROMPT If your hit ratio is high, your cache is probably large enough to hold
PROMPT your most frequently accessed data. In this case, you may be able to
PROMPT reduce the cache size and still maintain good performance. To make the
PROMPT buffer cache smaller, reduce the value of the initialization parameter
PROMPT DB_BLOCK_BUFFERS. The minimum value for this parameter is 4.
PROMPT You can apply any leftover memory to other Oracle memory structures.
PROMPT 
PROMPT Oracle can collect statistics to predict buffer cache performance based
PROMPT on a smaller cache size. Examining these statistics can help you
PROMPT determine how small you can afford to make your buffer cache without
PROMPT adversely affecting performance.
PROMPT 
PROMPT THE X$KCBCBH TABLE
PROMPT 
PROMPT The virtual table SYS.X$KCBCBH contains the statistics that estimate
PROMPT the performance of a smaller cache. The X$KCBCBH table is similar in
PROMPT structure to the X$KCBRBH table. This table can only be accessed by
PROMPT the user SYS. The following are the columns of the X$KCBCBH table:
PROMPT 
PROMPT INDX    The value of this column is the potential number of
PROMPT .       buffers in the cache.
PROMPT COUNT   The value of this column is the number of cache
PROMPT .       hits attributable to buffer number INDX.
PROMPT 
PROMPT The number of rows in this table is equal to the number of buffers in
PROMPT your buffer cache. Each row in the table reflects the number of cache
PROMPT attributed to a single buffer. For example, in the second row, the INDX
PROMPT value is 1 and the COUNT value is the number of cache hits for the
PROMPT second buffer. In the third row, the INDX value is 2 and the COUNT
PROMPT value is the number of cache hits for the third buffer.
PROMPT 
PROMPT The first row of the table contains special information. The INDX value
PROMPT is 0 and the COUNT value is the total number of blocks moved into the
PROMPT first buffer in the cache.
PROMPT 
PROMPT ENABLING THE X$KCBCBH TABLE
PROMPT 
PROMPT The collection of statistics in the X$KCBCBH table is controlled by the
PROMPT initialization parameter DB_BLOCK_LRU_STATISTICS. The value of
PROMPT this parameter determines whether Oracle collects the statistics. The
PROMPT default value for this parameter is FALSE, which means that the default
PROMPT behavior is not to collect statistics.
PROMPT 
PROMPT To enable the collection of statistics in the X$KCBCBH table, set the
PROMPT value of DB_BLOCK_LRU_STATISTICS to TRUE.
PROMPT 
PROMPT Collecting these statistics incurs some performance overhead. To avoid
PROMPT this overhead, collect statistics only when you are tuning the buffer
PROMPT cache and disable the collection of statistics when you are finished
PROMPT tuning.
PROMPT 
PROMPT A way to examine the X$KCBCBH table is to group the buffers
PROMPT in intervals.
PROMPT 

@_HIDE

COLUMN bufval NEW_VALUE nbuf NOPRINT
SELECT value bufval
FROM v$parameter
WHERE LOWER(name) = 'db_block_buffers';

COLUMN thits NEW_VALUE tot_hits NOPRINT
SELECT SUM(count) thits
FROM x$kcbcbh;

COLUMN bgets NEW_VALUE block_gets NOPRINT
SELECT value bgets
FROM v$sysstat
WHERE name = 'db block gets';

COLUMN cgets NEW_VALUE cons_gets NOPRINT
SELECT value cgets
FROM v$sysstat
WHERE name = 'consistent gets';

COLUMN preads NEW_VALUE phys_reads NOPRINT
SELECT value preads
FROM v$sysstat
WHERE name = 'physical reads';

@_SET
ACCEPT incr PROMPT "Define number of buffers in the interval (max = &nbuf): "
@_TITLE "Lost Hits if &nbuf Cache Buffers were Removed"

COLUMN interval     FORMAT A20          HEADING Interval 
COLUMN cache_hits   FORMAT 999,999,990  HEADING "Buffer cache hits"
COLUMN hit_ratio    FORMAT 999.99       HEADING "Hit ratio (%)"
COLUMN cum          FORMAT 999.99       HEADING 'Loss (%)'

SELECT
    LPAD(TO_CHAR(&&incr * TRUNC(indx / &&incr) + 1, '999,990'), 8) || ' to '||
    LPAD(TO_CHAR(&&incr * (TRUNC(indx / &&incr) +1), '999,990'), 8) interval,
    SUM(count) cache_hits,
    SUM(count) / &tot_hits * 100 cum,
    100 * (1 - ((&&phys_reads + SUM(count)) / 
        (&&block_gets + &&cons_gets))) hit_ratio
FROM
    sys.x$kcbcbh
WHERE
    indx > 0
GROUP BY
    TRUNC(indx / &&incr) ;

PROMPT
PROMPT Where:
PROMPT
PROMPT INTERVAL           Is the interval of buffers in the cache.
PROMPT
PROMPT BUFFER CACHE HITS  Is the number of cache hits conributable to the buffers 
PROMPT .                  in the INTERVAL column.
PROMPT
PROMPT LOSS               Is the percent off loss
PROMPT
PROMPT HIT RATIO          Is the hit ratio contributable to buffers
PROMPT .                  in the INTERVAL column.
PROMPT

UNDEFINE nbuf
UNDEFINE incr
UNDEFINE block_gets
UNDEFINE cons_gets
UNDEFINE phys_reads

@_END
