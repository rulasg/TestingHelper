[CmdletBinding()]
param ()

$ModuleName = "TestingHelper"

Import-Module -Name TestingHelper -Force

Test-Module -Name $ModuleName  


