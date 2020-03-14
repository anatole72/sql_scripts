REM
REM  Examine statistics in the X$KCBRBH table with intent 
REM  to expand the SGA.
REM
 
@_BEGIN

PROMPT
PROMPT REDUCING BUFFER CACHE MISSES
PROMPT 
PROMPT If your hit ratio is low, say less than 60% or 70%, then you may want to
PROMPT increase the number of buffers in the cache to improve performance. To
PROMPT make the buffer cache larger, increase the value of the initialization
PROMPT parameter DB_BLOCK_BUFFERS.
PROMPT 
PROMPT Oracle can collect statistics that estimate the performance gain that
PROMPT would result from increasing the size of your buffer cache. With these
PROMPT statistics, you can estimate how many buffers to add to your cache.
PROMPT
PROMPT THE X$KCBRBH TABLE
PROMPT 
PROMPT The virtual table SYS.X$KCBRBH contains statistics that estimate the
PROMPT performance of a larger cache. Each row in the table reflects the relative
PROMPT performance value of adding a buffer to the cache. This table can only
PROMPT be accessed by the user SYS. The following are the columns of the
PROMPT X$KCBRBH table:
PROMPT 
PROMPT INDX   The value of this column is one less than the
PROMPT .      number of buffers that would potentially be added
PROMPT .      to the cache.
PROMPT
PROMPT COUNT  The value of this column is the number of
PROMPT .      additional cache hits that would be obtained by
PROMPT .      adding buffer number INDX+1 to the cache.
PROMPT 
PROMPT For example, in the first row of the table, the INDX value is 0 and the
PROMPT COUNT value is the number of cache hits to be gained by adding the
PROMPT first additional buffer to the cache. In the second row, the INDX value
PROMPT is 1 and the COUNT value is the number of cache hits for the second
PROMPT additional buffer.
PROMPT 
PROMPT ENABLING THE X$KCBRBH TABLE
PROMPT 
PROMPT The collection of statistics in the X$KCBRBH table is controlled by the
PROMPT initialization parameter DB_BLOCK_LRU_EXTENDED_STATISTICS.
PROMPT The value of this parameter determines the number of rows in the
PROMPT X$KCBRBH table. The default value of this parameter is 0, which
PROMPT means the default behavior is to not collect statistics.
PROMPT To enable the collection of statistics in the X$KCBRBH table, set the
PROMPT value of DB_BLOCK_LRU_EXTENDED_STATISTICS. For example, if
PROMPT you set the value of the parameter to 100, Oracle will collect 100 rows
PROMPT of statistics, each row reflecting the addition of one buffer, up to 100
PROMPT extra buffers.
PROMPT 
PROMPT Collecting these statistics incurs some performance overhead. This
PROMPT overhead is proportional to the number of rows in the table. To avoid
PROMPT this overhead, collect statistics only when you are tuning the buffer
PROMPT cache and disable the collection of statistics when you are finished
PROMPT tuning.
PROMPT 
PROMPT A way to examine the X$KCBRBH table is to group the additional buffers in 
PROMPT large intervals.
PROMPT

@_HIDE

COLUMN bufval NEW_VALUE nbuf NOPRINT
SELECT value bufval
FROM v$parameter
WHERE LOWER(name) = 'db_block_lru_extended_statistics';

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
@_TITLE "Gained Hits if &nbuf Cache Buffers are Added"

COLUMN interval     FORMAT A20          HEADING Interval 
COLUMN cache_hits   FORMAT 999,999,990  HEADING "Buffer cache hits"
COLUMN hit_ratio    FORMAT 999.99       HEADING "Hit ratio (%)"

SELECT
    LPAD(TO_CHAR(&&incr * TRUNC(indx / &&incr) + 1, '999,990'), 8) || ' to ' ||
    LPAD(TO_CHAR(&&incr * (TRUNC(indx / &&incr) + 1), '999,990'), 8) interval,
    SUM(count) cache_hits,
    100 * (1 - ((&&phys_reads - SUM(count)) / 
        (&&block_gets + &&cons_gets))) hit_ratio
FROM
    sys.x$kcbrbh
WHERE
    indx > 0
GROUP BY
    TRUNC(indx / &&incr) ;

PROMPT
PROMPT Where:
PROMPT
PROMPT INTERVAL           Is the interval of additional buffers to be added to
PROMPT .                  the cache.
PROMPT
PROMPT BUFFER CACHE HITS  Is the number of additional cache hits to be gained
PROMPT .                  by adding the buffers in the INTERVAL column.
PROMPT
PROMPT HIT RATIO          Is the hit ratio to be gained by adding the buffers
PROMPT .                  in the INTERVAL column.
PROMPT

UNDEFINE nbuf
UNDEFINE incr
UNDEFINE block_gets
UNDEFINE cons_gets
UNDEFINE phys_reads

@_END
