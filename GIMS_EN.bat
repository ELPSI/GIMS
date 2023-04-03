@ECHO OFF
CHCP 65001 > NUL
:: File name:	GIMS
:: Author:		elpsy
:: Version:		1.0.4
:: Date:		20230402
:: Description	Create a file/folder mapping in a specified location using the original resource files of Genshin Impact game, applicable to sky-island server, world-tree server and international server.

CD /D %~DP0 & TITLE GIMS
SETLOCAL ENABLEDELAYEDEXPANSION
SET "logDate=%DATE:~3,4%%DATE:~8,2%%DATE:~11,2%"
SET "logTime=%TIME:~0,8%"
SET /A "successCount=0"
SET "oldGamePath=0"
SET "oldDataPath=0"
SET "oldDataType=0"
SET "oldServerName=0"
SET "newGamePath=0"
SET "newDataPath=0"
SET "newDataType=0"
SET "newServerName=0"
SET "resourceName=0"
SET "gameName=0"
SET "gameVersion=0"

:GET_PRIVILEGES
::Get system administrator privileges
IF EXIST "%SystemRoot%\SysWOW64" PATH %PATH%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
BCDEDIT >NUL
IF ERRORLEVEL 1 (GOTO UACPROMPT) ELSE (GOTO UACADMIN)
:UACPROMPT
%1 START "" MSHTA VBSCRIPT:CREATEOBJECT("SHELL.APPLICATION").SHELLEXECUTE("""%~0""","::",,"RUNAS",1)(WINDOW.CLOSE)&EXIT
EXIT /B
:UACADMIN
CD /D "%~DP0"
ECHO;&ECHO The administrator privilege has been obtained, and the current running path is: %CD%
IF NOT EXIST "log" MKDIR "log"
ECHO [%logTime%] INFO: Get system administrator privileges 1. >>log\log_%logDate%.log

ECHO [%logTime%] INFO: The processor architecture is: %PROCESSOR_ARCHITECTURE%.>>log\log_%logDate%.log
FOR /F "SKIP=1 TOKENS=1 DELIMS==" %%i IN ('VER') DO (
	SET "OSVersion=%%i"
)
ECHO [%logTime%] INFO: The OS version is: %OSVersion%.>>log\log_%logDate%.log

CALL :INITIALIZATION
::Check successCount
ECHO %successCount%|FINDSTR "^[1-9][0-9]*$" > NUL
IF ERRORLEVEL 1	(
	ECHO;&ECHO Detected that this is the first time to run this tool.
	ECHO [%logTime%] INFO: May be the first time to execute. >>log\log_%logDate%.log
	CALL :GET_OLDPATH_REG
) ELSE (
	ECHO;&ECHO It is detected that the Genshin Impact server has been successfully created.
	ECHO [%logTime%] INFO: Executed successfully in the past. >>log\log_%logDate%.log
)
CALL :CHOOSE_SERVER
IF "%newDataType%"=="%oldDataType%" (
	CALL :LAND_TREE
) ELSE (
	CALL :CN_SEA
)
CALL :UPDATECFG
CALL :CREATE_SHORTCUT
ECHO PAUSE>>log\manual.txt
ECHO;&ECHO The server is created, press any key to exit.
PAUSE>NUL & EXIT

:INITIALIZATION
ECHO CD /D %~DP0>log\manual.txt
ECHO CHCP 65001>>log\manual.txt
::Read cfg.ini
IF EXIST "cfg\cfg.ini" (
	FOR /F "TOKENS=1,2 DELIMS==" %%i IN (cfg\cfg.ini) DO (
		SET %%i=%%j
		IF ERRORLEVEL 1 (
			ECHO [%logTime%] ERROR: Failed to read config.ini. >>log\log_%logDate%.log
			CALL :FAILED_BREAK
		)
	)
) ELSE (
	ECHO [%logTime%] ERROR: Cfg.ini not found. >>log\log_%logDate%.log
	CALL :FAILED_BREAK
)
ECHO;&ECHO Reading configuration file...
ECHO [%logTime%] INFO: Cfg.ini start to read: >>log\log_%logDate%.log
>>log\log_%logDate%.log ECHO gameVersion=%gameVersion%
>>log\log_%logDate%.log ECHO landServerStatus=%landServerStatus%
>>log\log_%logDate%.log ECHO treeServerStatus=%treeServerStatus%
>>log\log_%logDate%.log ECHO seaServerStatus=%seaServerStatus%
>>log\log_%logDate%.log ECHO oldGamePath=%oldGamePath%
>>log\log_%logDate%.log ECHO oldServerName=%oldServerName%
>>log\log_%logDate%.log ECHO oldDataType=%oldDataType%
>>log\log_%logDate%.log ECHO newPath=%newPath%
>>log\log_%logDate%.log ECHO successCount=%successCount%
ECHO [%logTime%] INFO: Cfg.ini end reading.>>log\log_%logDate%.log
GOTO :EOF

:GET_OLDPATH_REG
SET "userErrorLevel=1"
FOR /F "SKIP=2 TOKENS=1,2 DELIMS=:" %%i IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\原神" /V "InstallPath"') DO (
	SET "value1=%%i"
	SET "value2=%%j"
	SET "userErrorLevel=0"
	SET "oldCNRegPath=!value1:~-1!:!value2!"
	SET "oldCNRegGamePath=!oldCNRegPath!\Genshin Impact game"
)
IF %userErrorLevel%==0 (
	IF EXIST "%oldCNRegGamePath%" (
		SET "CNRegStatus=1"
		ECHO [%logTime%] DEBUG: CNRegStatus=!CNRegStatus! >>log\log_%logDate%.log
		ECHO [%logTime%] INFO: CNserver client installation path in regedit exists:"%oldCNRegGamePath%". >>log\log_%logDate%.log
	) ELSE (
		SET "CNRegStatus=0"
		ECHO [%logTime%] DEBUG: CNRegStatus=!CNRegStatus! >>log\log_%logDate%.log
		ECHO [%logTime%] WARNING: CNserver client installation path in regedit NOT exists:"%oldCNRegGamePath%". >>log\log_%logDate%.log
	)
) ELSE (
	SET "CNRegStatus=0"
	ECHO [%logTime%] DEBUG: CNRegStatus=!CNRegStatus! >>log\log_%logDate%.log
	ECHO [%logTime%] WARNING: Failed to read CNserver client installation path from regedit. >>log\log_%logDate%.log
)
SET "userErrorLevel=1"
FOR /F "SKIP=2 TOKENS=1,2 DELIMS=:" %%i IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Genshin Impact" /V "InstallPath"') DO (
	SET "value1=%%i"
	SET "value2=%%j"
	SET "userErrorLevel=0"
	SET "oldSeaRegPath=!value1:~-1!:!value2!"
	SET "oldSeaRegGamePath=!oldSeaRegPath!\Genshin Impact game"
)
IF %userErrorLevel%==0 (
	IF EXIST "%oldSeaRegGamePath%" (
		SET "seaRegStatus=1"
		ECHO [%logTime%] DEBUG: seaRegStatus=!seaRegStatus! >>log\log_%logDate%.log
		ECHO [%logTime%] INFO: Seaserver client installation path in regedit exists:"%oldSeaRegGamePath%". >>log\log_%logDate%.log
	) ELSE (
		SET "seaRegStatus=0"
		ECHO [%logTime%] DEBUG: seaRegStatus=!seaRegStatus! >>log\log_%logDate%.log
		ECHO [%logTime%] WARNING: Seaserver client installation path in regedit NOT exists:"%oldSeaRegGamePath%". >>log\log_%logDate%.log
	)
) ELSE (
	SET "seaRegStatus=0"
	ECHO [%logTime%] DEBUG: seaRegStatus=!seaRegStatus! >>log\log_%logDate%.log
	ECHO [%logTime%] WARNING: Failed to read seaserver client installation path from regedit. >>log\log_%logDate%.log
)
IF %seaRegStatus%==1 (
	IF %CNRegStatus%==1 (
		SET "oldGamePath=%oldCNRegGamePath%"
		ECHO [%logTime%] DEBUG: oldGamePath=!oldGamePath! >>log\log_%logDate%.log
		CALL :JUDGE_SERVER_TYPE
	) ELSE (
		SET "oldGamePath=%oldSeaRegGamePath%"
		ECHO [%logTime%] DEBUG: oldGamePath=!oldGamePath! >>log\log_%logDate%.log
		CALL :JUDGE_SERVER_TYPE
	)
) ELSE (
	IF %CNRegStatus%==1 (
		SET "oldGamePath=%oldCNRegGamePath%"
		ECHO [%logTime%] DEBUG: oldGamePath=!oldGamePath! >>log\log_%logDate%.log
		CALL :JUDGE_SERVER_TYPE
	) ELSE (
		CALL :INPUT_OLDGAMEPATH
	)
)
GOTO :EOF

:INPUT_OLDGAMEPATH
ECHO;&ECHO _______________________________________________________________
ECHO;&ECHO Please enter the game installation path: click the right mouse button to paste here, and press the "Enter" key:
ECHO;&SET /P "oldGamePath=The game installation path is:"
IF EXIST "%oldGamePath%\mhypbase.dll" (
	ECHO;&ECHO The game installation path inputted exists, please continue...
	ECHO [%logTime%] INFO: OldGamePath exists: %oldGamePath%. >>log\log_%logDate%.log
) ELSE (
	ECHO;&ECHO The game installation path inputted does not exist, please check and re-input.
	GOTO INPUT_OLDGAMEPATH
)
CALL :JUDGE_SERVER_TYPE
GOTO :EOF

:READ_CONFIG_INI
CD /D "%oldGamePath%"
FOR /F "TOKENS=1,2 DELIMS==" %%i IN (config.ini) DO (
	SET "%%i=%%j"
	IF ERRORLEVEL 1 (
		ECHO [%logTime%] ERROR: Failed to read config.ini. >>%~DP0log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
)
CD /D %~DP0
ECHO [%logTime%] INFO: Config.ini start to read: >>log\log_%logDate%.log
ECHO channel=%channel% >>log\log_%logDate%.log
ECHO cps=%cps% >>log\log_%logDate%.log
ECHO game_version=%game_version% >>log\log_%logDate%.log
ECHO sub_channel=%sub_channel% >>log\log_%logDate%.log
ECHO [%logTime%] INFO: Config.ini end reading. >>log\log_%logDate%.log

SET "gameVersion=%game_version%"
GOTO :EOF

:JUDGE_SERVER_TYPE
CALL :READ_CONFIG_INI
IF EXIST "%oldGamePath%\GenshinImpact_Data" (
	IF NOT EXIST "%oldGamePath%\YuanShen_Data" (
		SET "oldServerName=Seaserver"
		SET "oldDataType=GenshinImpact_Data"
		SET /A "seaServerStatus=1"
		ECHO;&ECHO Detected that the original server is International server.
		ECHO [%logTime%] INFO: Seaserver detected. >>log\log_%logDate%.log
	) ELSE (
		ECHO;&ECHO The "Data" folder is duplicated, please download and install the game again.
		ECHO [%logTime%] ERROR: Both Yuanshen_Data and GenshinImpact_Data exist. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
) ELSE (
	IF EXIST "%oldGamePath%\YuanShen_Data" (
		IF %channel%==1 (
			SET "oldServerName=Landserver"
			SET "oldDataType=YuanShen_Data"
			SET /A "landServerStatus=1"
			ECHO;&ECHO Detected that the original Yuanshen server is Sky-Island server.
			ECHO [%logTime%] INFO: Landserver detected. >>log\log_%logDate%.log
		) ELSE (
			IF %channel%==14 (
				SET "oldServerName=Treeserver"
				SET "oldDataType=YuanShen_Data"
				SET /A "treeServerStatus=1"
				ECHO;&ECHO Detected that the original Yuanshen server is World-Tree server.
				ECHO [%logTime%] INFO: Treeserver detected. >>log\log_%logDate%.log
			) ELSE (
				ECHO;&ECHO The content of Config.ini is wrong.
				ECHO [%logTime%] ERROR: Config.ini error. >>log\log_%logDate%.log
				CALL :FAILED_BREAK
			)
		)
	) ELSE (
		ECHO;&ECHO The Data folder cannot be found, please download and install the game again.
		ECHO [%logTime%] ERROR: Game data directory error. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
)
GOTO :EOF

:CHOOSE_SERVER
::Choose new server type
SET /A "newServerStatus=0"
ECHO;&ECHO The original game installation path is: "%oldGamePath%"
FOR %%I in ("%oldGamePath%") DO SET "newGameDrive=%%~dI"
CHKNTFS %newGameDrive% >NUL 2>NUL
IF ERRORLEVEL 1 (
	ECHO;&ECHO %newGameDrive% is not NTFS. This tool is not currently supported. Please convert this partition to NTFS format or use another tool.
	ECHO [%logTime%] ERROR: %newGameDrive% is not NTFS. >>log\log_%logDate%.log
	CALL :FAILED_BREAK
) ELSE (
	ECHO;&ECHO %newGameDrive% is NTFS.
	ECHO [%logTime%] INFO: %newGameDrive% is NTFS. >>log\log_%logDate%.log
)

SET "newPath=%newGameDrive%\GenshinImpactNew"
IF NOT EXIST "%newPath%" (
	MD "%newPath%"
	ECHO MD "%newPath%">>log\manual.txt
)
ECHO;&ECHO The new game path default is: "%newPath%"
ECHO [%logTime%] DEBUG: newPath=%newPath%. >>log\log_%logDate%.log
REM ECHO;&ECHO _______________________________________________________________
ECHO;&ECHO Please select the type of game server you want to create:
ECHO;&ECHO 1.Sky-Island server (ID starts with the number 1 or 2).
ECHO;&ECHO 2.World-Tree server (ID starts with the number 5).
ECHO;&ECHO 3.International server (ID starts with the number 6, 7, 8 or 9).

:INPUT_SERVER
ECHO;&ECHO _______________________________________________________________
ECHO;&SET /P "newServerNum=Please enter the number 1, 2 or 3 and press the "Enter" key to continue:"

IF "%newServerNum%"=="1" (
	SET "newServerName=Landserver"
	SET "newServerStatus=%landServerStatus%"
) ELSE (
	IF "%newServerNum%"=="2" (
		SET "newServerName=Treeserver"
		SET "newServerStatus=%treeServerStatus%"
	) ELSE (
		IF "%newServerNum%"=="3" (
			SET "newServerName=Seaserver"
			SET "newServerStatus=%seaServerStatus%"
		) ELSE (
			ECHO;&ECHO Illegal input, please re-input.
			GOTO INPUT_SERVER
		)
	)
)
ECHO [%logTime%] DEBUG: newServerStatus=%newServerStatus% >>log\log_%logDate%.log
IF %newServerStatus%==1 (
	ECHO;&ECHO This server already exists, please choose another server.
	GOTO INPUT_SERVER
) ELSE (
	IF "%newServerName%"=="%oldServerName%" (
		ECHO;&ECHO This server already exists, please choose another server.
		GOTO INPUT_SERVER
	) ELSE (
		ECHO;&ECHO Waiting for server creation...
	)
)
IF "%newServerName%"=="Seaserver" (
	SET "resourceName=SeaRes_"
	SET "newDataType=GenshinImpact_Data"
	SET "gameName=GenshinImpact.exe"
) ELSE (
	SET "resourceName=CNRes_"
	SET "newDataType=YuanShen_Data"
	SET "gameName=YuanShen.exe"
)
SET "oldDataPath=%oldGamePath%\%oldDataType%"
SET "newGamePath=%newPath%\%newServerName%"
SET "newDataPath=%newPath%\%newServerName%\%newDataType%"

ECHO [%logTime%] INFO: New server: %newServerName%.>>log\log_%logDate%.log
ECHO [%logTime%] DEBUG: oldDataPath=%oldDataPath%>>log\log_%logDate%.log
ECHO [%logTime%] DEBUG: newGamePath=%newGamePath%>>log\log_%logDate%.log
ECHO [%logTime%] DEBUG: newDataPath=%newDataPath%>>log\log_%logDate%.log

IF NOT EXIST "%newGamePath%" (
	MD "%newGamePath%"
	ECHO MD "%newGamePath%">>log\manual.txt
)
IF NOT EXIST "%newDataPath%" (
	MD "%newDataPath%"
	ECHO MD "%newDataPath%">>log\manual.txt
)
GOTO :EOF

:CN_SEA
::Detect the resource in this folder (for CN to sea)
IF NOT EXIST "%~DP0%resourceName%V%gameVersion%" (
	ECHO;&ECHO Please confirm that "%resourceName%V%gameVersion%.exe" has been downloaded and press Enter to continue:
	PAUSE >NUL
	IF NOT EXIST "%resourceName%V%gameVersion%.exe" (
		ECHO;&ECHO "%resourceName%V%gameVersion%.exe" was not detected, please download again.
		GOTO CN_SEA
	) 
	ECHO;&ECHO Please unzip "%resourceName%V%gameVersion%.exe" to this folder, that is, just press OK in the pop-up dialog box.
	"%resourceName%V%gameVersion%.exe"
)
XCOPY /E /Y "%resourceName%V%gameVersion%\" "%newGamePath%">NUL
ECHO XCOPY /E /Y "%resourceName%V%gameVersion%\" "%newGamePath%">>log\manual.txt
ECHO;&ECHO Copying resource files to new game path...
IF ERRORLEVEL 1 (
	ECHO;&ECHO Failed to copy resources files.
	ECHO [%logTime%] DEBUG: ERRORLEVEL=%ERRORLEVEL%>>log\log_%logDate%.log
	ECHO [%logTime%] DEBUG: XCOPY /E /Y "%resourceName%V%gameVersion%\" "%newGamePath%">>log\log_%logDate%.log
	ECHO [%logTime%] ERROR: Failed to copy resources files. >>log\log_%logDate%.log
	CALL :FAILED_BREAK
) ELSE (
	ECHO [%logTime%] INFO: Copy resources successfully. >>log\log_%logDate%.log
)
CALL :COPY_TREESDK
::Make link (for CN to sea)
ECHO;&ECHO Start creating links...
FOR /F "EOL=# DELIMS==" %%i IN (cfg\listdir_cn_sea.ini) DO (
	IF NOT EXIST "%oldDataPath%\%%i" (
		ECHO [%logTime%] ERROR: Folder to link not exists: %oldDataPath%\%%i. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
	IF NOT EXIST "%newDataPath%\%%i" (
		MKLINK /D "%newDataPath%\%%i" "%oldDataPath%\%%i" >NUL
		ECHO MKLINK /D "%newDataPath%\%%i" "%oldDataPath%\%%i">>log\manual.txt
		IF ERRORLEVEL 1 (
			ECHO [%logTime%] ERROR: Folder linked unsuccessfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
			CALL :FAILED_BREAK
		) ELSE (
			ECHO [%logTime%] INFO: Folder linked successfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
		)
	) ELSE (
		ECHO [%logTime%] WARNING: Folder link exists: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
	)
)
FOR /F "eol=# delims==" %%i in (cfg\listfile_cn_sea.ini) do (
	IF NOT EXIST "%oldDataPath%\%%i" (
		ECHO [%logTime%] ERROR: File to link not exists: %oldDataPath%\%%i. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
	IF NOT EXIST "%newDataPath%\%%i" (
		MKLINK "%newDataPath%\%%i" "%oldDataPath%\%%i">NUL
		ECHO MKLINK "%newDataPath%\%%i" "%oldDataPath%\%%i">>log\manual.txt
		IF ERRORLEVEL 1 (
			ECHO [%logTime%] ERROR: File linked unsuccessfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
			CALL :FAILED_BREAK
		) ELSE (
			ECHO [%logTime%] INFO: File linked successfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
		)
	) ELSE (
		ECHO [%logTime%] WARNING: File link exists: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
	)
)
GOTO :EOF

:LAND_TREE
::check newServerName is treeserver or not (for land to tree)
IF "%newServerName%"=="Treeserver" (
	::Copy PCGameSDK.dll for treeserver (for land to tree)
	IF NOT EXIST "%newDataPath%" (
		MD "%newDataPath%"
		ECHO MD "%newDataPath%">>log\manual.txt
	)
	IF NOT EXIST "%newDataPath%\Plugins" (
		MD "%newDataPath%\Plugins"
		ECHO MD "%newDataPath%\Plugins">>log\manual.txt
	)
	CALL :COPY_TREESDK
)
::Copy listfile_gamecn files (for land to tree)
ECHO [%logTime%] INFO: Start to copy files according to listfile_gamecn. >>log\log_%logDate%.log
	FOR /F "eol=#" %%i in (cfg\listfile_gamecn.ini) do (
		COPY /Y "%oldGamePath%\%%i" "%newGamePath%\%%i">NUL
		ECHO COPY /Y "%oldGamePath%\%%i" "%newGamePath%\%%i">>log\manual.txt
		IF ERRORLEVEL 1 (
			ECHO [%logTime%] DEBUG: ERRORLEVEL=%ERRORLEVEL%>>log\log_%logDate%.log
			ECHO [%logTime%] DEBUG: COPY /Y "%oldGamePath%\%%i" "%newGamePath%\%%i">>log\log_%logDate%.log
			ECHO [%logTime%] ERROR: Failed to copy file: %%i. >>log\log_%logDate%.log
			CALL :FAILED_BREAK
		) ELSE (
			ECHO [%logTime%] INFO: Copy file successfully: %%i. >>log\log_%logDate%.log
		)
)
ECHO [%logTime%] INFO: End copying listfile_gamecn. >>log\log_%logDate%.log
::Make directory list and make link (for land to tree)
ECHO;&ECHO Start creating links...
FOR /F "EOL=# DELIMS==" %%i IN (cfg\listdir_land_tree.ini) DO (
	IF NOT EXIST "%oldDataPath%\%%i" (
		ECHO [%logTime%] ERROR: Folder to link not exists: %oldDataPath%\%%i. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
	IF NOT EXIST "%newDataPath%\%%i" (
		MKLINK /D "%newDataPath%\%%i" "%oldDataPath%\%%i" >NUL
		ECHO MKLINK /D "%newDataPath%\%%i" "%oldDataPath%\%%i">>log\manual.txt
		IF ERRORLEVEL 1 (
			ECHO [%logTime%] ERROR: Folder linked unsuccessfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
			CALL :FAILED_BREAK
		) ELSE (
			ECHO [%logTime%] INFO: Folder linked successfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
		)
	) ELSE (
		ECHO [%logTime%] WARNING: Folder link exists: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
	)
)
FOR /F "eol=# delims==" %%i in (cfg\listfile_land_tree.ini) do (
	IF NOT EXIST "%oldDataPath%\%%i" (
		ECHO [%logTime%] ERROR: File to link not exists: %oldDataPath%\%%i. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	)
	IF NOT EXIST "%newDataPath%\%%i" (
		MKLINK "%newDataPath%\%%i" "%oldDataPath%\%%i">NUL
		ECHO MKLINK "%newDataPath%\%%i" "%oldDataPath%\%%i">>log\manual.txt
		IF ERRORLEVEL 1 (
			ECHO [%logTime%] ERROR: File linked unsuccessfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
			CALL :FAILED_BREAK
		) ELSE (
			ECHO [%logTime%] INFO: File linked successfully: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
		)
	) ELSE (
		ECHO [%logTime%] WARNING: File link exists: %newDataPath%\%%i %oldDataPath%\%%i. >>log\log_%logDate%.log
	)
)
GOTO :EOF

:COPY_TREESDK
::Copy PCGameSDK.dll for treeserver (for CN to sea)
IF "%newServerName%"=="Treeserver" (
	IF NOT EXIST "PCGameSDK.dll" (
		ECHO;&ECHO Please confirm that "PCGameSDK.dll" has been downloaded and press Enter to continue:
		PAUSE >NUL
		IF NOT EXIST "PCGameSDK.dll" (
			ECHO;&ECHO "PCGameSDK.dll" was not detected, please download again.
			GOTO COPY_TREESDK
		)
	)
	COPY /Y "PCGameSDK.dll" "%newDataPath%\Plugins\PCGameSDK.dll">NUL
	ECHO COPY /Y "PCGameSDK.dll" "%newDataPath%\Plugins\PCGameSDK.dll">>log\manual.txt
	ECHO;&ECHO Copying PCGameSDK.dll to new path...
	IF ERRORLEVEL 1 (
		ECHO [%logTime%] DEBUG: ERRORLEVEL=%ERRORLEVEL%>>log\log_%logDate%.log
		ECHO [%logTime%] DEBUG: COPY /Y "PCGameSDK.dll" "%newDataPath%\Plugins\PCGameSDK.dll">>log\log_%logDate%.log
		ECHO [%logTime%] ERROR: Fail to copy PCGameSDK.dll. >>log\log_%logDate%.log
		CALL :FAILED_BREAK
	) ELSE (
		ECHO [%logTime%] INFO: Copy PCGameSDK.dll successfully. >>log\log_%logDate%.log
	)
)
GOTO :EOF

:UPDATECFG
::Update data in cfg.ini
IF %newServerName%==Landserver (
	SET /A "landServerStatus=1"
	SET "shortcutName=Sky-Island server"
	SET "channel=1"
	SET "cps=mihoyo"
) ELSE (
	IF %newServerName%==Treeserver (
		SET /A "treeServerStatus=1"
		SET "shortcutName=World-Tree server"
		SET "channel=14"
		SET "cps=bilibili"
	) ELSE (
		IF %newServerName%==Seaserver (
			SET /A "seaServerStatus=1"
			SET "shortcutName=International server"
			SET "channel=1"
			SET "cps=mihoyo"
		)
	)
)
CD /D %~DP0
ECHO [%logTime%] INFO: Config.ini start to update:>>log\log_%logDate%.log
>"%newGamePath%\config.ini" ECHO channel=%channel%
>>"%newGamePath%\config.ini" ECHO cps=%cps%
>>"%newGamePath%\config.ini" ECHO game_version=%gameVersion%
>>"%newGamePath%\config.ini" ECHO sub_channel=%sub_channel%
ECHO [%logTime%] INFO: Config.ini end updating.>>log\log_%logDate%.log
SET /A "successCount+=1"
ECHO [%logTime%] INFO: Cfg.ini start to update: >>log\log_%logDate%.log
>cfg\cfg.ini ECHO gameVersion=%gameVersion%
>>cfg\cfg.ini ECHO landServerStatus=%landServerStatus%
>>cfg\cfg.ini ECHO treeServerStatus=%treeServerStatus%
>>cfg\cfg.ini ECHO seaServerStatus=%seaServerStatus%
>>cfg\cfg.ini ECHO oldGamePath=%oldGamePath%
>>cfg\cfg.ini ECHO oldServerName=%oldServerName%
>>cfg\cfg.ini ECHO oldDataType=%oldDataType%
>>cfg\cfg.ini ECHO newPath=%newPath%
>>cfg\cfg.ini ECHO successCount=%successCount%
ECHO [%logTime%] INFO: Cfg.ini end updating.>>log\log_%logDate%.log
GOTO :EOF

:CREATE_SHORTCUT
::Create desktop shortcut
mshta VBScript:Execute("Set a=CreateObject(""WScript.Shell""):Set b=a.CreateShortcut(a.SpecialFolders(""Desktop"") & ""\%shortcutName%.lnk""):b.TargetPath=""%newGamePath%\%gameName%"":b.WorkingDirectory=""%newGamePath%"":b.Save:close")
ECHO [%logTime%] INFO: Genshin Impact server create successfully. >>log\log_%logDate%.log
GOTO :EOF

:FAILED_BREAK
::This is failed break
ECHO;&ECHO Failed to create server, press any key to exit.
ECHO [%logTime%] ERROR: This is failed break. >>log\log_%logDate%.log
PAUSE>NUL && EXIT