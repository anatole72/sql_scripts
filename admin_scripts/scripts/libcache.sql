REM
REM  Generate a library cache report
REM

@_BEGIN
@_TITLE "LIBRARY CACHE SUMMARY STATISTICS"

COLUMN pins                    HEADING 'Pins|(Executes)'
COLUMN pinhits                 HEADING 'Pin |Hits'
COLUMN phitrat  FORMAT 990.99  HEADING 'Pin |Hit%'
COLUMN reloads                 HEADING 'Reloads|(Misses)'
COLUMN hitrat   FORMAT 990.99  HEADING 'Hit%'
COLUMN bad      FORMAT A4      HEADING 'Bad?|<99%'

SELECT
    SUM(Pins) pins,
    SUM(PinHits) pinhits,
    ((SUM(PinHits) / SUM(Pins)) * 100) phitrat,
    SUM(Reloads) reloads,
    ((SUM(Pins) / (SUM(Pins) + SUM(Reloads))) * 100) hitrat,
    DECODE(SIGN(SUM(Pins) / (SUM(Pins) + SUM(Reloads)) - 0.99),
        1, '   ', 'BAD') bad
FROM
    v$librarycache
/

@_TITLE "LIBRARY CACHE STATISTICS (SQL AND PL/SQL)"

COLUMN namespace                        HEADING "Namespace"
COLUMN gets                             HEADING "Gets|(Parses)"
COLUMN gethitratio      FORMAT 999.99   HEADING "Get |Hit%"
COLUMN bad              FORMAT A4       HEADING "Bad?|<90%"
COLUMN pins                             HEADING "Pins|(Executes)"
COLUMN pinhitratio      FORMAT 999.99   HEADING "Pin |Hit%"
COLUMN reloads                          HEADING "Reloads|(Misses)"
COLUMN invalidations                    HEADING "Invali-|dations"

SELECT
    namespace,
    gets,
    gethitratio * 100 gethitratio,
    DECODE(namespace, 'SQL AREA',
        DECODE(SIGN(gethitratio - 0.9), 1, '   ', 'BAD')) bad,
    pins,
    pinhitratio * 100 pinhitratio,
    reloads,
    invalidations
FROM
    v$librarycache
WHERE
    SUBSTR(namespace, 1, 2) NOT IN (
        'IN', 'CL', 'OB', 'PI'
    ) 
/

@_TITLE "LIBRARY CACHE STATISTICS (DEPENDENCIES)"

SELECT
    namespace,
    gets,
    gethitratio * 100 gethitratio,
    pins,
    pinhitratio * 100 pinhitratio,
    reloads,
    invalidations
FROM
    v$librarycache
WHERE
    SUBSTR(namespace, 1, 2) IN (
        'IN', 'CL', 'OB', 'PI'
    ) 
/

UNDEFINE ord
@_END
