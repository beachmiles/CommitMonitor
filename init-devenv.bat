REM init Visual Studio
CALL "%VS140COMNTOOLS%\vsvars32.bat"

REM init PATH
::set drivep=C:\programming\devenv\strawberry-perl-5.20.3.1-32bit-portable
::set PATH=C:\Program Files\Python27;%WIX%\bin;C:\programming\devenv\nant-0.92\bin;%drivep%\perl\site\bin;%drivep%\perl\bin;%drivep%\c\bin;%PATH%


SET mypath=%~dp0
echo Changing directory to script path %mypath:~0,-1%
cd /d %mypath:~0,-1%

echo starting build
nant -buildfile:default.build setup
