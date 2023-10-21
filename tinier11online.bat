@echo off
setlocal EnableExtensions EnableDelayedExpansion

title tinier11 builder online
@echo Welcome to the tinier11 online tool!

@rem pretty colors
color 1e

@rem clean dism log
del /f /q %windir%\Logs\DISM\dism.log %windir%\Logs\DISM\DismAppx.log >NUL

@echo Getting Application Packages long names
dism /Online /Get-ProvisionedAppxPackages | findstr PackageName>%TEMP%\longAppPackageNames.txt

@echo Preparing Long Package Names List for removal
@rem get pure long package names
del /f /q %TEMP%\pureLongAppPackageNames.txt 2>NUL
FOR /F "eol=# tokens=3" %%i IN (%TEMP%\longAppPackageNames.txt) DO @echo.%%i>>%TEMP%\pureLongAppPackageNames.txt
@rem get uncommented short app package names
del /f /q %TEMP%\uncomAppPackageNames.txt 2>NUL
FOR /F "eol=#" %%i IN (%~dp0appPackageNames.txt) DO @echo.%%i>>%TEMP%\uncomAppPackageNames.txt

@rem keep only long package names, which are found in short package names list
@findstr /B /L /G:%TEMP%\uncomAppPackageNames.txt %TEMP%\pureLongAppPackageNames.txt >%TEMP%\longAppPackageNamesToRemove.txt

@rem pause Check %TEMP%\longAppPackageNamesToRemove.txt
@echo Removing app packages per prepared list
FOR /F %%i IN (%TEMP%\longAppPackageNamesToRemove.txt) DO dism /Online /Remove-ProvisionedAppxPackage /PackageName:%%i

@echo Removing of system apps complete! Now proceeding to removal of system packages...

@echo Get System Package List
dism /Online /Get-Packages | findstr /C:"Package Identity : ">%TEMP%\longSysPackageNames.txt
@echo Preparing System Long Package Names List for removal

@rem get pure long package names
@del /f /q %TEMP%\pureLongSysPackageNames.txt 2>NUL
FOR /F "eol=# tokens=4" %%i IN (%TEMP%\longSysPackageNames.txt) DO @echo.%%i>>%TEMP%\pureLongSysPackageNames.txt

@rem get uncommented short sys package names
@del /f /q %TEMP%\uncomSysPackageNames.txt 2>NUL
FOR /F "eol=#" %%i IN (%~dp0sysPackageNames.txt) DO @echo.%%i>>%TEMP%\uncomSysPackageNames.txt

@rem keep only long package names, which are found in short package names list
@findstr /B /L /G:%TEMP%\uncomSysPackageNames.txt %TEMP%\pureLongSysPackageNames.txt >%TEMP%\LongSysPackageNamesToRemove.txt

@rem pause Check %TEMP%\LongSysPackageNamesToRemove.txt

@echo Removing sys packages per prepared list
FOR /F %%i IN (%TEMP%\LongSysPackageNamesToRemove.txt) DO dism /Online /Remove-Package /PackageName:%%i

@rem Capabilities seem to match AppPackages and SysPackages - so I keep the list commented out
echo Get Capabilities
dism /Online /Get-Capabilities /LimitAccess | findstr /C:"Capability Identity : ">%TEMP%\longCapabilties.txt

@rem get only long Capability names
@del /f /q %TEMP%\pureLongCapabilties.txt 2>NUL
FOR /F "eol=# tokens=4" %%i IN (%TEMP%\longCapabilties.txt) DO @echo.%%i>>%TEMP%\pureLongCapabilties.txt

@rem get uncommented capability names
@del /f /q %TEMP%\uncomCapabilityNames.txt 2>NUL
FOR /F "eol=#" %%i IN (%~dp0capabilityNames.txt) DO @echo.%%i>>%TEMP%\uncomCapabilityNames.txt

@rem keep only long capability names, which are found in short capability names list
@findstr /B /L /G:%TEMP%\uncomCapabilityNames.txt %TEMP%\pureLongCapabilties.txt >%TEMP%\LongCapabiltiesToRemove.txt

@rem pause Check %TEMP%\LongCapabiltiesToRemove.txt

@rem echo Removing capabilities
@rem dism /Online /Remove-Capability /CapabilityName:App.StepsRecorder~~~~0.0.1.0
echo Removing Capabilities
FOR /F %%i IN (%TEMP%\LongCapabiltiesToRemove.txt) DO dism /Online /Remove-Capability /CapabilityName:%%i

@rem Get features - those can be later enabled/disable via appwiz.cpl
@rem dism /Online /Get-features /Format:List >%TEMP%\features.txt

@rem get uncommented Feature names
@del /f /q %TEMP%\uncomFeatureNames.txt 2>NUL
FOR /F "eol=#" %%i IN (%~dp0featureNames.txt) DO @echo.%%i>>%TEMP%\uncomFeatureNames.txt

@rem pause Check %TEMP%\uncomFeatureNames.txt

@echo Disable features: port-sharing, Media playback/player, WorkFolders, InternetPrinting
FOR /F %%i IN (%TEMP%\uncomFeatureNames.txt) DO dism /Online /Disable-Feature /FeatureName:%%i /Remove

:Stop
@echo Creation completed! Press any key to exit the script...
pause
endlocal
