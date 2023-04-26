[CmdletBinding()]
param ()


# As we are testing TestingHelper from TestingHelper we need to differentiate the Testing with the Tested versions
# New Test-ModulelocalPSD1 that will find the tested version. This way this script will call the testing version of TestingHelper. 

# As we are using Test-ModulelocalPSD1 first present on this version of the module we use testing with tested.
# We need to import the tested from here. This need to be removed on next version where testing has this function
Import-Module -Name ./TestingHelper.psd1 -Force
Import-Module -Name TestingHelper

Test-ModulelocalPSD1