[CmdletBinding()]
param ()

$ModuleName = "TestingHelper"

Import-Module -Name TestingHelper -Force

Test-Module -Name $ModuleName -TestName TestingHelperTest_CountTimes_*
