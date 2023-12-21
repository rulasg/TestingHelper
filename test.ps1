<#
.SYNOPSIS
    Run tests
.DESCRIPTION
    Run the unit test of the actual module
.NOTES
    Using TestingHelper this script will search for a Test module and run the tests
    This script will be referenced from launch.json to run the tests on VSCode
.LINK
    https://raw.githubusercontent.com/rulasg/StagingModule/main/test.ps1
.EXAMPLE
    > ./test.ps1
#>

[CmdletBinding()]
param (
    [Parameter()][switch]$ShowTestErrors
)

function Set-TestName{
    [CmdletBinding()]
    [Alias("st")]
    param (
        [Parameter(Position=0,ValueFromPipeline)][string]$TestName
    )

    process{
        $global:TestName = $TestName
    }
}

function Get-TestName{
    [CmdletBinding()]
    [Alias("gt")]
    param (
    )

    return $global:TestName
}

function Clear-TestName{
    [CmdletBinding()]
    [Alias("ct")]
    param (
    )

    $global:TestName = $null
}

function Import-RequiredModules{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)][string]$Name,
        [Parameter()][string]$Version,
        [Parameter()][switch]$AllowPrerelease,
        [Parameter()][switch]$PassThru
    )
    process{
        "Importing module Name[{0}] Version[{1}] AllowPrerelease[{2}]" -f $Name, $Version, $AllowPrerelease | Write-Host -ForegroundColor DarkGray

        if ($Version) {
            $V = $Version.Split('-')
            $semVer = $V[0]
            $AllowPrerelease = ($AllowPrerelease -or ($null -ne $V[1]))
        }
        
        $module = Import-Module $Name -PassThru -ErrorAction SilentlyContinue -RequiredVersion:$semVer
        
        if ($null -eq $module) {
            "Installing module Name[{0}] Version[{1}] AllowPrerelease[{2}]" -f $Name, $Version, $AllowPrerelease | Write-Host -ForegroundColor DarkGray
            $installed = Install-Module -Name $Name -Force -AllowPrerelease:$AllowPrerelease -passThru -RequiredVersion:$Version
            $module = Import-Module -Name $installed.Name -RequiredVersion ($installed.Version.Split('-')[0]) -Force -PassThru
        }
        
        if ($PassThru) {
            $module
        }
    }
}

# TestingHelper
Import-RequiredModules -Name TestingHelper -AllowPrerelease

# Required Modules
$localPath = $PSScriptRoot
$requiredModule = $localPath | Join-Path -child "*.psd1" |  Get-Item | Import-PowerShellDataFile | Select-Object -ExpandProperty requiredModules
$requiredModule | Import-RequiredModules -AllowPrerelease

if($TestName){
    Invoke-TestingHelper -TestName $TestName -ShowTestErrors:$ShowTestErrors
} else {
    Invoke-TestingHelper -ShowTestErrors:$ShowTestErrors
}
