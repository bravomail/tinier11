@rem The script to get the names of app/system packages and features.
@rem Those names will surprisingly vary between various Windows versions.
@rem You can then use those names to put into appPackageNames.txt featureNames.txt sysPackageNames.txt
@rem Creating your own trimmed down Windows.
@rem The results are stored in .\sortedShortAppPackageNames.txt
@rem   .\sortedShortSysPackageNames.txt
@rem   .\sortedShortCapabilties.txt
@rem   .\sortedEnabledWinFeatures.txt

@echo off
setlocal EnableExtensions EnableDelayedExpansion

@rem use script's directory for all temporary files/dirs
cd /D %~dp0

@rem pretty colors
color 1e

@rem set ESC for colorful messages
set "ESC="

@rem set the title
title tinier11 get package and feature names
@echo.tinier11 get package and feature names

@rem Get Windows ISO mounted drive letter
set DriveLetter=
set /p DriveLetter=Please enter the drive letter for the Windows 10/11 image:
set "DriveLetter=%DriveLetter%:"
@echo.

@rem verify if boot.wim exists on a chosen Windows ISO path
if exist "%DriveLetter%\sources\boot.wim" goto bootWimFound

call :showerror "Can't find %DriveLetter%\sources\boot.wim. Please enter the correct DVD Drive Letter."
@goto :Stop

:noWimFileFound
if exist "%DriveLetter%\sources\install.esd" goto installFound

call :showerror "Can't find %DriveLetter%\sources\install.wim or install.esd. Please enter the correct DVD Drive Letter."
@goto :Stop

:bootWimFound
@rem verify if install.wim exists on a chosen Windows ISO path
if not exist "%DriveLetter%\sources\install.wim" goto noWimFileFound

:installFound
@rem pre-cleanup of temp dirs
rd /s /q tinier11 2>NUL
rd  /s /q scratchdir 2>NUL

@echo Copying Windows image to .\tinier11...
md tinier11
xcopy.exe /E /I /H /R /Y /J %DriveLetter% .\tinier11 >nul || ( call :showerror "XCOPY failed. Check if you have enough disk space." & goto Stop )
@echo.Copy complete!

@rem clean dism log
del /f /q %windir%\Logs\DISM\dism.log %windir%\Logs\DISM\DismAppx.log >NUL

@rem Check if we have to export from ESD compressed version
if exist "%DriveLetter%\sources\install.wim" goto imageReady 

@echo.install.wim needs exporting from install.esd file...
@echo.
dism /Get-WimInfo /wimFile:%~dp0tinier11\sources\install.esd || (call :showerror "Dism /Get-WimInfo failed. You should run this script as an Administrator. Check the error above." & goto Stop )
@echo.
@rem Choose a Windows version, enter only the number:
set SrcIdx=
set /p SrcIdx=Please enter the image index:
set "SrcIdx=%SrcIdx%"
set "index=1"
@echo.

dism /Export-image /SourceImageFile:%~dp0tinier11\sources\install.esd /SourceIndex:%SrcIdx% /DestinationImageFile:%~dp0tinier11\sources\install.wim /Compress:max /CheckIntegrity

del /f /q %~dp0tinier11\sources\install.esd
goto goTime

:imageReady
@echo.Getting image information:
dism /Get-WimInfo /wimfile:%~dp0tinier11\sources\install.wim || (call :showerror "Dism /Get-WimInfo failed. You should run this script as an Administrator. Check the error above." & goto Stop )
set index=
set /p index=Please enter the image index:
set "index=%index%"

:goTime
@echo.Mounting Windows image. This may take a while.
@echo.
md %~dp0scratchdir
dism /mount-image /imagefile:%~dp0tinier11\sources\install.wim /index:%index% /mountdir:%~dp0scratchdir || ( call :showerror "Mounting image install.wim failed. Check if you have enough disk space. And your volume should be NTFS." & goto Stop )
@echo.Mounting complete!

del /F /Q %TEMP%\longAppPackageNames.txt >NUL 2>NUL
@echo.Get Application Packages - .\sortedShortAppPackageNames.txt
dism /image:%~dp0scratchdir /Get-ProvisionedAppxPackages | findstr PackageName>%TEMP%\longAppPackageNames.txt

@rem get pure long App package names
del /f /q %TEMP%\pureLongAppPackageNames.txt >NUL 2>NUL
FOR /F "eol=# tokens=3" %%i IN (%TEMP%\longAppPackageNames.txt) DO @echo.%%i>>%TEMP%\pureLongAppPackageNames.txt

@rem shorten app package names by "_", and get unique sorted list
del /f /q %TEMP%\pureShortAppPackageNames.txt >NUL 2>NUL
FOR /F "tokens=1 delims=_" %%i IN (%TEMP%\pureLongAppPackageNames.txt) DO @echo.%%i>>%TEMP%\pureShortAppPackageNames.txt
%windir%\System32\sort.exe /UNIQUE %TEMP%\pureShortAppPackageNames.txt /O .\sortedShortAppPackageNames.txt

@echo.Get Sys Packages - .\sortedShortSysPackageNames.txt
dism /image:%~dp0scratchdir /Get-Packages | findstr /C:"Package Identity : ">%TEMP%\longSysPackageNames.txt

@rem get pure long package names
@del /f /q %TEMP%\pureLongSysPackageNames.txt >NUL 2>NUL
FOR /F "eol=# tokens=4" %%i IN (%TEMP%\longSysPackageNames.txt) DO @echo.%%i>>%TEMP%\pureLongSysPackageNames.txt

@rem shorten sys package names by "~", and get unique sorted list
del /f /q %TEMP%\pureShortSysPackageNames.txt >NUL 2>NUL
FOR /F "tokens=1 delims=~" %%i IN (%TEMP%\pureLongSysPackageNames.txt) DO @echo.%%i>>%TEMP%\pureShortSysPackageNames.txt
%windir%\System32\sort.exe /UNIQUE %TEMP%\pureShortSysPackageNames.txt /O .\sortedShortSysPackageNames.txt

@rem Capabilities seem to match AppPackages and SysPackages - so I keep the list commented out
echo.Get Capabilities - .\sortedShortCapabilties.txt
dism /image:%~dp0scratchdir /Get-Capabilities /LimitAccess | findstr /C:"Capability Identity : ">%TEMP%\longCapabilties.txt

@rem get only long Capability names
@del /f /q %TEMP%\pureLongCapabilties.txt >NUL 2>NUL
FOR /F "eol=# tokens=4" %%i IN (%TEMP%\longCapabilties.txt) DO @echo.%%i>>%TEMP%\pureLongCapabilties.txt

@rem shorten capability names by "~", and get unique sorted list
del /f /q %TEMP%\pureShortCapabilties.txt >NUL 2>NUL
FOR /F "tokens=1 delims=~" %%i IN (%TEMP%\pureLongCapabilties.txt) DO @echo.%%i>>%TEMP%\pureShortCapabilties.txt
%windir%\System32\sort.exe /UNIQUE %TEMP%\pureShortCapabilties.txt /O .\sortedShortCapabilties.txt

@echo.Get features - .\sortedEnabledWinFeatures.txt
dism /image:%~dp0scratchdir /Get-features /Format:List >%TEMP%\winFeatures.txt

@rem only leave feature name and its state - we are interested in Enabled ones
findstr /C:"Feature Name : " /C:"State : " %TEMP%\winFeatures.txt >%TEMP%\pureWinFeatures.txt

@rem spit out only "Enabled" feature names
del /F /Q %TEMP%\enabledWinFeatures.txt >NUL 2>NUL
set "prevline="
FOR /F "tokens=*" %%A IN (%TEMP%\pureWinFeatures.txt) DO ( IF "%%A"=="State : Enabled" echo.!prevline!>>%TEMP%\enabledWinFeatures.txt ) & set prevline=%%A

@rem keep only feature names and sort them
@del /f /q %TEMP%\pureEnabledWinFeatures.txt >NUL 2>NUL
FOR /F "eol=# tokens=4" %%i IN (%TEMP%\enabledWinFeatures.txt) DO @echo.%%i>>%TEMP%\pureEnabledWinFeatures.txt
%windir%\System32\sort.exe /UNIQUE %TEMP%\pureEnabledWinFeatures.txt /O .\sortedEnabledWinFeatures.txt

echo.Unmount scratch image
dism /unmount-image /mountdir:%~dp0scratchdir /Discard || ( call :showerror "Dism Unmount install.wim failed." & goto Stop )

:Stop
@rem Performing Cleanup...
rd /s /q %~dp0tinier11 >NUL 2>NUL
rd /s /q %~dp0scratchdir >NUL 2>NUL
del /F /Q %TEMP%\longAppPackageNames.txt %TEMP%\longSysPackageNames.txt %TEMP%\longCapabilties.txt %TEMP%\winFeatures.txt %TEMP%\pureShortAppPackageNames.txt %TEMP%\pureShortSysPackageNames.txt %TEMP%\pureShortCapabilties.txt %TEMP%\enabledWinFeatures.txt %TEMP%\pureEnabledWinFeatures.txt %TEMP%\pureLongSysPackageNames.txt %TEMP%\pureLongCapabilties.txt %TEMP%\pureWinFeatures.txt %TEMP%\pureLongAppPackageNames.txt >NUL 2>NUL

@echo.
@echo.
@echo.Package and feature names are in following files:
@echo.
dir /N sortedShortAppPackageNames.txt sortedShortSysPackageNames.txt sortedShortCapabilties.txt sortedEnabledWinFeatures.txt
@echo.End of tinier11GetNames script...
pause
endlocal
goto quit

@rem simple echo fails to color stdout after the error. subroutine works.
:showerror
@echo.%ESC%[91m%~1%ESC%[93m
:quit
