@ECHO OFF
CHCP 65001 > NUL

CD /D %~DP0 & TITLE Reset cfg.ini
SET /P "gameVersion=Please input gameVersion(For example:3.5.0),end with inputting "Enter" key: "
IF NOT EXIST "cfg" (
	MD "cfg"
)

>cfg\cfg.ini ECHO gameVersion=%gameVersion%
>>cfg\cfg.ini ECHO landServerStatus=0
>>cfg\cfg.ini ECHO treeServerStatus=0
>>cfg\cfg.ini ECHO seaServerStatus=0
>>cfg\cfg.ini ECHO oldGamePath=0
>>cfg\cfg.ini ECHO oldServerName=0
>>cfg\cfg.ini ECHO oldDataType=0
>>cfg\cfg.ini ECHO newPath=0
>>cfg\cfg.ini ECHO successCount=0
EXIT

