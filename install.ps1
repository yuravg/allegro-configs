#!/usr/bin/env powershell

# Installation script (PowerShell, Windows OS)
#
# it creates symbolic links in the HOME directory pointing to local files
#

Write-Host "Crete links"
Write-Host "Environment variable 'HOME': " $env:HOME

$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

Write-host "Source directory: $dir"

Function Make-DirLink {
    Param (
        [string]$source,
        [string]$target
    )
    Process {
        if (Test-Path $target -PathType Container)
        {
            Write-Host "`nWARNING: Directory/Link already exists: " $target
            Write-Host "Exit without creating link!`n"
        } else
        {
            New-Item -ItemType Junction -Value $source -Path $target
        }
    }
}

Make-DirLink (Join-path $dir pcbenv) (Join-path $env:HOME "pcbenv")

Write-Host ""
pause
