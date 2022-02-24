@echo off
setlocal EnableExtensions EnableDelayedExpansion

if not "%~1"=="" pushd "%~1" || exit /B 1

set "rmFolders="
choice /M "Remove original folders?"
if %errorlevel% == 1 set "rmFolders=y"
echo,

set /A "count=0"
for /D %%X in (*) do (
    set /A "count+=1"
    echo Folder !count!: %%X

    7z.exe a "%%X.zip" -tzip -mx0 -r ".\%%X\*" > nul || exit /B 1

    for /F "delims=" %%O in ("%%X.zip") do (
        call :prettysize zipsize %%~zO
        echo Size ~ !zipsize!
    )

    if defined rmFolders (
        rmdir /S /Q "%%X"
        echo Folder deleted.
    )

    echo,
)

echo Done.
pause
exit /B 0

rem Get human-readable size from bytes.
:prettysize & rem Args: 1:outputVariable 2:size
setlocal EnableExtensions EnableDelayedExpansion
set "unit=B"
set /A "size=%~2, roundup=0"

for %%U in (KB MB GB TB) do (
    if !size! geq 1024 (
        set "unit=%%U"
        set /A "roundup = size & 512, size >>= 10"
    )
)
if %roundup% gtr 0 set /A "size+=1"

endlocal & set "%~1=%size% %unit%"
exit /B 0
