<#
.SYNOPSIS
    Run tests
.DESCRIPTION
    Run the unit test of the actual module
.NOTES
    Using TestingHelper this script will search for a Test module and run the tests
    This script will be referenced from launch.json to run the tests on VSCode
.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/test.ps1
.EXAMPLE
    > ./test.ps1
#>

[CmdletBinding()]
param (
    #Switch ShowTestErrors
    [Parameter()][switch]$ShowTestErrors
)

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
# Invoke-TestingHelper -ShowTestErrors:$ShowTestErrors -TestName TestingHelperTest_AddTestToModuleAll_Simple
# Invoke-TestingHelper -ShowTestErrors:$ShowTestErrors -TestName TestingHelperTest_NewModuleV3_AddModule_DefaultManifest
# Invoke-TestingHelper -ShowTestErrors:$ShowTestErrors -TestName TestingHelperTest_AddTest*
Invoke-TestingHelper -ShowTestErrors:$ShowTestErrors
