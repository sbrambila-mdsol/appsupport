::This is a backup script for Tableau Server

@echo ON

:: Let's grab a consistent date in the same format that Tableau Server writes the date to the end of the backup file name
:set_date
FOR /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') DO SET "dt=%%a"
SET "YY=%dt:~2,2%" & SET "YYYY=%dt:~0,4%" & SET "MM=%dt:~4,2%" & SET "DD=%dt:~6,2%"
SET "HH=%dt:~8,2%" & SET "Min=%dt:~10,2%" & SET "Sec=%dt:~12,2%"
SET "mydate=%YYYY%-%MM%-%DD%-%HH%-%MM%-%Sec%"


SET filename="ts_backup"
:: Customize the backupdays if you need to change it
SET backupdays="3"

:: Then we take the backup
:bakup
ECHO %date% %time% : Backing up Tableau Server data
CALL tsm maintenance backup -f ts_backup -d 

:: Rename File - Customize this to where your Tableau Server installation is
Ren "F:\Tableau Server\data\tabsvc\files\backups\*.tsbak" Tableau-%mydate%.tsbak"

:: Copy files from tableau default location - Customize this to where your Tableau Server installation is
copy "F:\Tableau Server\data\tabsvc\files\backups\*.tsbak"  \\prdtsr10db1\H\QATableauBackups\

move "F:\Tableau Server\data\tabsvc\files\backups\*.tsbak" F:\Backups

:: Check for previous backups and remove backup files older than N days
:delete_old_files
ECHO %date% %time% : Cleaning out backup files older than %backupdays% days
FORFILES -p "F:\backups" /m *.tsbak /D -3 /C "cmd /c del @file"

:: Specify location where you want to move your Tableau Server backup to. For example the file server
NET USE V: \\prdtsr10db1\H
FORFILES -p V:\QATableauBackups /m *.tsbak /D -3 /C "cmd /c del @file"