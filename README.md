# tinier11

Script to build a trimmed-down Windows 10/11 image without TPM, hardware or MS Sign-in requirements.
Insired by tiny11 builder.

## Description
This is a script to automate the build of a streamlined Windows 10/11 image, similar to tiny11.
Uses Microsoft dism, xcopy, reg and oscdimg utiltites.
Included is an autounattend.xml answer file, which is used to bypass the MS account on OOBE, remove MS Teams and to deploy the image with the /compact flag.
It should work on any build of Windows 11 (see Windows 10 notes below).
What is removed: check appPackageNames.txt featureNames.txt sysPackageNames.txt - customize by deleting lines or commenting with "#".
MS Edge and OneDrive removed conditionally - see sysPackageNames.txt.

There is also online/live Win10/11 debloater now available: tinier11online.bat
It runs on your live Windows 10/11 machine.
It uses the same text files for removing app and sys packages/features. But it doesn't remove MS Edge and OneDrive, or tweak TPM.

## Before you start
0. You need working Windows 10 or 11 machine.
1. Get oscdimg.exe from Windows ADK https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install
and put into the same directory as bat file (or into one of may PATH locations).
2. About 12GB free NTFS file system space. Script can run on any NTFS location (including RAM disk) and will create temp files inside its folder, about 3x the size of Windows ISO you have.

## Instructions:
1. Download latest Windows 10/11 from UUPDump (without customizations/drivers/patches/.NET etc) or from the Microsoft website (<https://www.microsoft.com/software-download/windows11>).
2. Mount the downloaded ISO image using Windows Explorer.
3. Edit/review appPackageNames.txt featureNames.txt sysPackageNames.txt - and comment-out with '#' things you don't want to remove.
4. Copy win10/autounattend.xml over to script folder - if you are customizing Windows 10.
5. Run "tinier11.bat" as Admin.
6. Select the drive letter where the image is mounted (only the letter, no colon (:)) - for example "F".
7. Select the image index that you want the image to be based. For example, "1.Windows Home", "2. Windows Pro", "3. Education" - enter "2".
8. When the work is completed, you will see it in the folder where the script was extracted, with the name "tinier11.iso".

## After work is done
1. I suggest renaming ISO file to something meaningful like "tinier11pro.iso". The script will preserve/rename any previous existing "tinier11.iso" file by renaming it with date/time-stamp.
2. Word of caution - test your created ISO within VirtualBox/VMware/QEMU or other similar free virtual environment - before trying to run on a real machine.
3. There are post-install optimizations of Windows possible. Stay tuned for more.

## Known issues:
1. Windows 11 autounattend.xml file is not compatible with Windows 10. So I created a separate autounattend.xml file for Windows 10.
2. Although Edge is removed, the icon and a ghost of its taskbar pin are still available. Also, there are some remnants in the Settings. But the app in itself is deleted.
3. Windows Update sometimes manages to reinstall a lot of things - MS Edge, WebExperience etc. They can be manually removed. Let me know if there is a way to permanently block their installation.
4. Windows 10 x86 (32 bit) is not compatible with autounattend.xml - I'm working to get the working one. Meanwhile - just remove autounattend.xml from script dir if you are on x86 Windows 10.

## Improvements compared to tiny11
Removed hard dependencies on Windows build number.
Added customizable debloat options with the ability to add new ones as they come (coPilot?).
No hardcoded fixed C: locations for temp dirs. You can run the script on RAMdisk to avoid SSD wear.
No binaries - you download them yourself.
Proper error handling with red error text to boot.
Preservation of previously created tinier11.iso.
Needless timeout pauses removed.
A lot of comments to understand the script.

## Is there a virus or trojan?
There are no binaries supplied, get them from trusted Microsoft websites, and the script source is highly readable and commented. There is no URL invocation of any kind, so nothing suspiciois will be slip-streamed into your ISO.

## Any upcoming Improvements?
As Windows 11 is rapidly changes there will be more packages added to it, and I will keep my packages updated.
There might be some light registry tweaks added.
There will be some improvements to autounattend.xml to do fine tuning.
