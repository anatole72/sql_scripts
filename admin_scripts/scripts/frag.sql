REM 
REM  Displays database fragmentation chart
REM 
REM  Author: Mark Lang, 1998
REM

PROMPT
PROMPT DATABASE FRAGMENTATION CHART
PROMPT
ACCEPT ts PROMPT "Tablespace name like (ENTER for all): "
PROMPT

@_BEGIN
SET SERVEROUTPUT ON SIZE 10240

DECLARE

    dbnm    VARCHAR2(8);
    files   NUMBER;
    sizem   NUMBER;
    freem   NUMBER;
    pctf    NUMBER;
    pieces  NUMBER;
    biggest NUMBER;
    lt100k  NUMBER;
    dead    NUMBER;
    mexts   NUMBER;
    nsegs   NUMBER;
    gt10e   NUMBER;
    gt100e  NUMBER;
    moste	NUMBER;

BEGIN

    SELECT name INTO dbnm FROM v$database;

    DBMS_OUTPUT.PUT_LINE(
        'FREE SPACE - ' ||
        RPAD(dbnm, 8) ||
        ' +------------- FREE ------------+ +------  USED ------+'
    );
    DBMS_OUTPUT.PUT_LINE(
        'Tspace       Fl SizeM FreeM %Fre Piecs BigsM <100k Dead NmSegs >10e >100 Most'
    );
    DBMS_OUTPUT.PUT_LINE(
        '------------ -- ----- ----- ---- ----- ----- ----- ---- ------ ---- ---- ----'
    );

    FOR r IN (
        SELECT *
        FROM sys.ts$
        WHERE online$ = 1
        AND name LIKE NVL(UPPER('&&ts'), '%')
        ORDER BY name
    ) LOOP

        SELECT
            COUNT(*),
            SUM(blocks) * r.blocksize
        INTO files, sizem
        FROM sys.file$ fl, v$dbfile vf
        WHERE fl.ts# = r.ts#
        AND fl.file# = vf.file#;	-- Make sure dropped files don't show

        SELECT
            SUM(length) * r.blocksize,
            DECODE(SUM(length), 0, 100, SUM(length) * r.blocksize * 100 / sizem),
            COUNT(*),
            MAX(length) * r.blocksize,
            SUM(DECODE(SIGN(length * r.blocksize - 100 * 1024), 1, 0, 1)),
            SUM(DECODE(SIGN(length - 5), 1, 0, 1))
        INTO freem, pctf, pieces, biggest, lt100k, dead
        FROM sys.fet$ fs
        WHERE fs.ts# = r.ts#;

        SELECT
            SUM(COUNT(*)),
            SUM(DECODE(SIGN(MAX(ext#) - 10), -1, 0, 1)),
            SUM(DECODE(SIGN(MAX(ext#) - 100), -1, 0, 1)),
            MAX(MAX(ext#))
        INTO nsegs, gt10e, gt100e, moste
        FROM sys.uet$ us
        WHERE us.ts# = r.ts#
        GROUP BY segfile#, segblock#;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.name, 12) || ' ' ||
            LPAD(LTRIM(TO_CHAR(files, '99')), 2) || ' ' ||
            LPAD(LTRIM(TO_CHAR(sizem / (1024 * 1024), '9,990')), 5) || ' ' ||
            LPAD(LTRIM(TO_CHAR(freem / (1024 * 1024), '9,990')), 5) || ' ' ||
            LPAD(LTRIM(TO_CHAR(pctf, '990')) || '%', 4) || ' ' ||
            LPAD(LTRIM(TO_CHAR(pieces, '9,990')), 5) || ' ' ||
            LPAD(LTRIM(TO_CHAR(biggest / (1024 * 1024), '9,990')), 5) || ' ' ||
            LPAD(LTRIM(TO_CHAR(lt100k, '9,990')), 5) || ' ' ||
            LPAD(LTRIM(TO_CHAR(dead, '9990')), 4) || ' ' ||
            LPAD(LTRIM(TO_CHAR(nsegs, '99,990')), 6) || ' ' ||
            LPAD(LTRIM(TO_CHAR(gt10e, '9990')), 4) || ' ' ||
            LPAD(LTRIM(TO_CHAR(gt100e, '9990')), 4) || ' ' ||
            LPAD(LTRIM(TO_CHAR(moste, '990')), 4)
        );
    END LOOP;

END;
/
@_END

