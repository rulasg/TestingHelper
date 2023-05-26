 #Modules
function New-ModuleV1 {
<#
.Synopsis
   Created a Powershell module with BiT21 format.
#>
    [CmdletBinding()]
    [Alias("New-Module")] # Set default V2 on release v3.0
    [OutputType([System.IO.FileInfo])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Description,
        [Parameter()][string]$Path,
        [Parameter()][switch]$AvoidModuleFile,
        [Parameter()][switch]$AvoidTestFile,
        [Parameter()][String]$AppendToModuleFile
    )    

    $AUTHOR = 'rulasg'
    $ModuleName = $Name

    if (!$Path) {
        $Path = '.'
    }

    $modulePath = Join-Path -Path $Path -ChildPath $Name

    if(Test-Path($modulePath)){
        throw "Folder already exists"
    } else {
       $null = New-Item -ItemType Directory -Name $modulePath
    }

    # Manifest
    $filename = "$ModuleName.psd1"
    
    New-ModuleManifest `
        -Path (Join-Path -Path $modulePath -ChildPath $filename) `
        -RootModule "$ModuleName.psm1" `
        -Author        $AUTHOR `
        -ModuleVersion '0.1' `
        -Description   $Description `
        #-CompanyName   "rulasg" `
        #-Copyright     "(c) 2021 rulasg. All rights reserved."  `
        # -RequiredModules 'BaseSDK' `
        # -DefaultCommandPrefix $ModuleName 

    # Module File
    if (-Not $AvoidModuleFile)
    {
        NewModulefile -Path $modulePath -ModuleName $ModuleName -Author $AUTHOR -Description $Description -Append $AppendToModuleFile
    }    

    # Testing module
    if (-Not $AvoidTestFile)
    {
        New-TestingModule -Path $modulePath -ModuleName $ModuleName
        New-TestingVsCodeLaunchJson -Path $modulePath -ModuleName $ModuleName
    }

    return $modulePath
} Export-ModuleMember -Function New-ModuleV1 -Alias New-ModuleV1

function NewModulefile($Path, $ModuleName, $Author, $Description, $Append){
    $myString = 
@'
<# 
.Synopsis 
_XMODULE_

.Description
_DESCRIPTION_

.Notes 
NAME  : _XMODULE_.psm1*
AUTHOR: _AUTHOR_   

CREATED: _CREATED_TIME_
#>

Write-Host "Loading _XMODULE_ ..." -ForegroundColor DarkCyan
'@
    $myString = $myString.Replace('_XMODULE_',$ModuleName)
    $myString = $myString.Replace('_DESCRIPTION_',$Description)
    $myString = $myString.Replace('_AUTHOR_',$AUTHOR)
    $myString = $myString.Replace('_CREATED_TIME_',(Get-Date).ToShortDateString());

    if ($Append) {
        $myString+=$Append
    }

    $myString |  Out-File -FilePath (Join-Path -Path $Path -ChildPath "$ModuleName.psm1")
} 
function New-TestingModule($Path, $ModuleName){

    $testingModuleName = $ModuleName + "Test"

    $testScript = 
@'
[CmdletBinding()]
param ()

$ModuleName = "_XMODULE_"

Import-Module -Name TestingHelper -Force

Test-Module -Name $ModuleName 
'@

    $testingModulePs1 = "$TestingModuleName.ps1"
    
    $testScript = $testScript.Replace('_XMODULE_',$ModuleName)
    $testScript = $testScript.Replace('_CREATED_TIME_',(Get-Date).ToShortDateString());
    
    $testScript |  Out-File -FilePath (Join-Path -Path $Path -ChildPath $testingModulePs1)

    $toAppend =
@'


function _MODULE_TESTING__Sample(){
    Assert-IsTrue -Condition $true
}

Export-ModuleMember -Function _MODULE_TESTING__*
'@

    $toAppend = $toAppend.Replace('_MODULE_TESTING_',$testingModuleName)

    $null = New-Module -Path $Path -Name $testingModuleName -Description "Testing module for $ModuleName" -AvoidTestFile -AppendToModuleFile $toAppend
}   
function New-TestingVsCodeLaunchJson($Path, $ModuleName){
    $testScript = 
@'
    {
        // Use IntelliSense to learn about possible attributes.
        // Hover to view descriptions of existing attributes.
        // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
        "version": "0.2.0",
        "configurations": [
            {
                "name": "PowerShell: _XMODULE_.ps1",
                "type": "PowerShell",
                "request": "launch",
                "script": "${workspaceFolder}/_XMODULE_Test.ps1",
                "cwd": "${workspaceFolder}"
            }
        ]
    }
'@

    $testScript = $testScript.Replace('_XMODULE_',$ModuleName)

    New-Item `
        -ItemType File `
        -Path (Join-Path -Path $Path -ChildPath '.vscode' -AdditionalChildPath 'launch.json') `
        -Value $testScript `
        -Force `
        | Out-Null
}