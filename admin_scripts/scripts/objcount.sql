REM
REM  This scripts provides you with a listing of all
REM  object types by user.
REM

@_BEGIN
@_TITLE 'Object Count By User'

SET NUMWIDTH 4
BREAK ON REPORT
COMPUTE SUM LABEL TOTAL OF Tab ON REPORT
COMPUTE SUM LABEL TOTAL OF Ind ON REPORT
COMPUTE SUM LABEL TOTAL OF Syn ON REPORT
COMPUTE SUM LABEL TOTAL OF Vew ON REPORT
COMPUTE SUM LABEL TOTAL OF Seq ON REPORT
COMPUTE SUM LABEL TOTAL OF Trg ON REPORT
COMPUTE SUM LABEL TOTAL OF Fun ON REPORT
COMPUTE SUM LABEL TOTAL OF Pck ON REPORT
COMPUTE SUM LABEL TOTAL OF Prc ON REPORT
COMPUTE SUM LABEL TOTAL OF Dep ON REPORT

SELECT  
    SUBSTR(username, 1, 29) username,
    COUNT(DECODE(o.type, 2, o.obj#, '')) Tab,
    COUNT(DECODE(o.type, 1, o.obj#, '')) Ind,
    COUNT(DECODE(o.type, 5, o.obj#, '')) Syn,
    COUNT(DECODE(o.type, 4, o.obj#, '')) Vew,
    COUNT(DECODE(o.type, 6, o.obj#, '')) Seq,
    COUNT(DECODE(o.type, 7, o.obj#, '')) Prc,
    COUNT(DECODE(o.type, 8, o.obj#, '')) Fun,
    COUNT(DECODE(o.type, 9, o.obj#, '')) Pck,
    COUNT(DECODE(o.type,12, o.obj#, '')) Trg,
    COUNT(DECODE(o.type,10, o.obj#, '')) Dep
FROM    
    sys.obj$ o,  
    sys.dba_users u
WHERE   
    u.user_id = o.owner# (+)
GROUP BY 
    username
;
@_END
   
