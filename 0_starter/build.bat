@echo off

where odin.exe >nul 2>nul
if ["%ERRORLEVEL%"] neq ["0"] (
	echo Failed to find odin.exe
	echo Please download odinlang from github
	echo https://github.com/odin-lang/Odin/releases

	echo.
	echo Upon download and extracting, make sure odin.exe is in your
	echo PATH environment variable. You'll know it works when you open
	echo a new cmd.exe process and typing "odin version" provides the
	echo version of odin you have downloaded.

	pause
	goto :eof
)

if not exist "out\release" mkdir "out\release"
if not exist "out\debug" mkdir "out\debug"

echo Building Client [Debug]...
odin.exe build client.odin -file ^
-strict-style -vet -vet-using-param -vet-cast -vet-tabs ^
-o:none -debug -out:.\out\debug\client.exe

echo Building Client [Release]...
odin.exe build client.odin -file ^
-strict-style -vet -vet-using-param -vet-cast -vet-tabs ^
-o:aggressive -out:.\out\release\client.exe

echo Building Server [Debug]...
odin.exe build server.odin -file ^
-strict-style -vet -vet-using-param -vet-cast -vet-tabs ^
-o:none -debug -out:.\out\debug\server.exe

echo Building Server [Release]...
odin.exe build server.odin -file ^
-strict-style -vet -vet-using-param -vet-cast -vet-tabs ^
-o:aggressive -out:.\out\release\server.exe

