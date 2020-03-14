REM
REM  Lists all jobs that are currently running in the local database
REM

@_BEGIN
@_TITLE "RUNNING JOBS"

COLUMN sess FORMAT 99   HEADING 'Ses'
COLUMN jid  FORMAT 999  HEADING 'Id'
COLUMN subu FORMAT A10  HEADING 'Submitter' TRUNC
COLUMN secd FORMAT A10  HEADING 'Security'  TRUNC
COLUMN proc FORMAT A20  HEADING 'Job'       WORD_WRAPPED
COLUMN lsd  FORMAT A5   HEADING 'Last|Ok|Date'
COLUMN lst  FORMAT A5   HEADING 'Last|Ok|Time'
COLUMN nrd  FORMAT A5   HEADING 'This|Run|Date'
COLUMN nrt  FORMAT A5   HEADING 'This|Run|Time'
COLUMN fail FORMAT 99   HEADING 'Err'

SELECT
    djr.sid                        sess,
    djr.job                         jid,
    dj.log_user                    subu,
    dj.priv_user                   secd,
    dj.what                        proc,
    TO_CHAR(djr.last_date, 'MM/DD') lsd,
    SUBSTR(djr.last_sec, 1, 5)      lst,
    TO_CHAR(djr.this_date, 'MM/DD') nrd,
    SUBSTR(djr.this_sec, 1, 5)      nrt,
    djr.failures                    fail
FROM
    sys.dba_jobs dj,
    sys.dba_jobs_running djr
WHERE
    djr.job = dj.job
/

@_END

