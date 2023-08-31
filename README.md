# SentinelOne_Maintance_Check
Maintenance script to check and install SentinelOne on computers.

This Syncro MSP script has the following platform/environmetn varible assigned at runtime:

Variable Name - $SiteToken
Variable Type - platform
Value - {{customer_custom_field_sentinelone_site_token}}

The {{customer_custom_field_sentinelone_site_token}} varible is a Syncro Customer Custom field with the name: SentinelOne Site Token

The installer file needs to be added to Syncro script files.
File: FileSentinelOneInstaller_windows_64bit_v23_1_4_650.exe
Destination File Name (full path): C:\Support\SentinelAgent.exe

File Type - PowerShell
Run as - System
Max Script Run Time (minutes) - 10
