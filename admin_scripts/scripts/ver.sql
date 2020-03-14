REM 
REM  Show product version information and installed options
REM 

@_BEGIN
SET HEADING OFF

COLUMN banner FORMAT A60 WRAP

SELECT banner
FROM v$version;

SELECT 'With ' || parameter || ' option'
FROM v$option
WHERE value = 'TRUE';

SELECT '(' || parameter || ' option not installed' || ')'
FROM v$option
WHERE value <> 'TRUE';

@_END
