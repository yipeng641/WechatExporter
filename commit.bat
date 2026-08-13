@echo off
setlocal

cd /d "%~dp0"

where git >nul 2>&1
if errorlevel 1 (
    echo Error: Git was not found in PATH.
    exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo Error: This script is not inside a Git repository.
    exit /b 1
)

set "COMMIT_MESSAGE=%~1"
if not defined COMMIT_MESSAGE (
    set "COMMIT_MESSAGE=chore: update project files"
    set "PAUSE_ON_EXIT=1"
)

git add --all
if errorlevel 1 goto :failed

git diff --cached --quiet
set "DIFF_STATUS=%ERRORLEVEL%"
if "%DIFF_STATUS%"=="0" (
    echo No changes to commit.
    if defined PAUSE_ON_EXIT pause
    exit /b 0
)
if not "%DIFF_STATUS%"=="1" goto :failed

set "GIT_AUTHOR_NAME=yipeng641"
set "GIT_AUTHOR_EMAIL=yipeng@1postpro.com"
set "GIT_COMMITTER_NAME=yipeng641"
set "GIT_COMMITTER_EMAIL=yipeng@1postpro.com"

git commit -m "%COMMIT_MESSAGE%"
if errorlevel 1 goto :failed

echo.
echo Commit created as yipeng641 ^<yipeng@1postpro.com^>.
git log -1 --oneline
if defined PAUSE_ON_EXIT pause
exit /b 0

:failed
echo.
echo Commit failed.
if defined PAUSE_ON_EXIT pause
exit /b 1
