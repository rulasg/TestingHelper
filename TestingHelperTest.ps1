[CmdletBinding()]
param ()

function Import-TestingHelper($Version){

    if (-not (import-Module TestingHelper -RequiredVersion $Version -PassThru -ErrorAction SilentlyContinue )) {
        Install-Module -Name TestingHelper -Force -RequiredVersion $Version
        Import-Module -Name TestingHelper -Force -RequiredVersion $Version
    }
}

# As we are testing TestingHelper from TestingHelper we need to differentiate the Testing with the Tested versions
# Using new Test-ModulelocalPSD1 that will find and load the tested version on the root folder.
# Using Import-Module to import a released teating version of TestingHelper

# As we are using Test-ModulelocalPSD1 first present on this version of the module we use testing with tested.
# We need to import the tested from here. 
# This need to be removed on next version where testing has this function
Import-Module -Name ./TestingHelper.psd1 -Force
Import-TestingHelper -Version 2.0

Test-ModulelocalPSD1