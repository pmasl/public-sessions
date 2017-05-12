@ECHO OFF

SETLOCAL
SET SCENARIONAME=DISK3

IF "%1"=="" (
  @ECHO Warning: SQLSERVER env var undefined - assuming a default SQL instance. 
  SET SQLSERVER=.\SQL2016
) ELSE (
  SET SQLSERVER=%1
)

REM ========== Setup ========== 
@ECHO %date% %time% - Starting scenario %SCENARIONAME%...
CALL ..\common\Cleanup.cmd %SQLSERVER%
IF "%ERRORLEVEL%" NEQ "0" GOTO :eof
@ECHO %date% %time% - %SCENARIONAME% setup...
REM sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorks2016CTP3 -ooutput\Setup.out -iSetup.sql %NULLREDIRECT%

REM Limit SQL memory so that a scan of the 399MB table will always be disk-bound
REM sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorks2016CTP3 -ooutput\SetupMemory.out -Q"EXEC sp_configure 'show advanced', 1 RECONFIGURE WITH OVERRIDE EXEC sp_configure 'max server memory', 399 RECONFIGURE WITH OVERRIDE"  %NULREDIRECT%

REM ========== Start ========== 
REM Kick off a simulated workload so that we have a bit more interesting data to work with
@ECHO %date% %time% - Starting background workload...
SET /A NUMTHREADS=%NUMBER_OF_PROCESSORS%/2
IF %NUMTHREADS% LSS 1 SET NUMTHREADS=1
CALL ..\common\BackgroundWorkload.cmd %SQLSERVER% %NUMTHREADS% %NULLREDIRECT%

REM Start expensive query
@ECHO %date% %time% - Starting foreground queries...
CALL ..\common\StartN.cmd /N 2 /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iProblemQuery.sql -dAdventureWorks2016CTP3 2^> output\ProblemQuery.err > NUL
CALL ..\common\StartN.cmd /N 2 /C ..\common\loop.cmd sqlcmd.exe -S%SQLSERVER% -E -iProblemQuery2.sql -dAdventureWorks2016CTP3 2^> output\ProblemQuery2.err > NUL

@ECHO %date% %time% - Press ENTER to end the scenario. 
pause %NULLREDIRECT%
@ECHO %date% %time% - Shutting down...


REM ========== Cleanup ========== 
REM sqlcmd.exe -S%SQLSERVER% -E -dAdventureWorks2016CTP3 -iLocalCleanup.sql %NULLREDIRECT%
REM CALL ..\common\Cleanup.cmd %SQLSERVER%

