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

function Clear-TestName{
    [CmdletBinding()]
    [Alias("ct")]
    param (
    )

    $global:TestName = $null
}

function Import-TestingHelper{
    [CmdletBinding()]
    param (
        [Parameter()][string]$Version,
        [Parameter()][switch]$AllowPrerelease,
        [Parameter()][switch]$PassThru
    )
    
    if ($Version) {
        $V = $Version.Split('-')
        $semVer = $V[0]
        $AllowPrerelease = ($AllowPrerelease -or ($null -ne $V[1]))
    }
    
    $module = Import-Module TestingHelper -PassThru -ErrorAction SilentlyContinue -RequiredVersion:$semVer

    if ($null -eq $module) {
        $installed = Install-Module -Name TestingHelper -Force -AllowPrerelease:$AllowPrerelease -passThru -RequiredVersion:$Version
        $module = Import-Module -Name $installed.Name -RequiredVersion ($installed.Version.Split('-')[0]) -Force -PassThru
    }

    if ($PassThru) {
        $module
    }
}

Import-TestingHelper -AllowPrerelease

# Run test by PSD1 file
# Test-ModulelocalPSD1 -ShowTestErrors:$ShowTestErrors 
# Test-ModulelocalPSD1 -ShowTestErrors:$ShowTestErrors -TestName StagingModuleTest_*

if($TestName){
    Test-ModulelocalPSD1 -ShowTestErrors:$ShowTestErrors -TestName $TestName
} else {
    Test-ModulelocalPSD1 -ShowTestErrors:$ShowTestErrors
}