@echo off
setlocal
cd /d "%~dp0"
where cl >nul 2>nul
if errorlevel 1 exit /b 1
if /I not "%VSCMD_ARG_TGT_ARCH%"=="x86" (echo Please use an x86 Native Tools Command Prompt. & exit /b 1)
if not exist build mkdir build
if not exist dist mkdir dist
set OCTO_TARGET=OctoEnchantVisualsDiagnostic
set OCTO_DEFINES=/DOCTO_DIAGNOSTIC
cl /nologo /EHsc /std:c++17 /MT /W4 /WX /I src tests\visual_pair_test.cpp /Fe:build\visual_pair_test.exe /Fo:build\visual_pair_test.obj
if errorlevel 1 exit /b 1
build\visual_pair_test.exe
if errorlevel 1 exit /b 1
cl /nologo /c /O2 /MT /I vendor\minhook-1.3.4\include /Fo:build\ vendor\minhook-1.3.4\src\buffer.c vendor\minhook-1.3.4\src\hook.c vendor\minhook-1.3.4\src\trampoline.c vendor\minhook-1.3.4\src\hde\hde32.c
if errorlevel 1 exit /b 1
cl /nologo /c /O2 /MT /EHsc /std:c++17 /W4 /WX %OCTO_DEFINES% /I vendor\minhook-1.3.4\include /Fo:build\OctoEnchantVisuals.obj src\OctoEnchantVisuals.cpp
if errorlevel 1 exit /b 1
link /nologo /DLL /MACHINE:X86 /DYNAMICBASE /NXCOMPAT /MAP:build\%OCTO_TARGET%.map /OUT:dist\%OCTO_TARGET%.dll build\OctoEnchantVisuals.obj build\buffer.obj build\hook.obj build\trampoline.obj build\hde32.obj kernel32.lib
exit /b %errorlevel%
