[CmdletBinding()]
param ()

$ModuleName = "TestingHelper"

Import-Module -Name ./TestingHelper.psd1 -Force
Import-Module -Name TestingHelper

# Test-Module -Name $ModuleName 
# Test-ModulelocalPSD1 -TestName TestingHelperTest_ImportTestingModule_TargetModule_NotMatchingVerion
Test-ModulelocalPSD1