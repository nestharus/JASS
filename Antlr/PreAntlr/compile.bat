@Echo off
Pushd "%~dp0"
cd bin
echo %CD%
jar -cf AntlrCompile.jar compile