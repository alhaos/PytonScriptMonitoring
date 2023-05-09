@echo off
title start_soft5
set "marker_1=40"
set "marker_2=300"
set "name=I:\soft\start_soft5\main.py"
cd /d "I:\soft\start_soft5"
rem start "" python "%name%"
powershell -executionpolicy bypass -file "C:\Users\Administrator\Desktop\test\process.ps1" %marker_1% %marker_2% %name%