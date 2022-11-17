[CmdletBinding()]
param ()

$ModuleName = "TestingHelper"

Import-Module -Name ./TestingHelper.psd1 -Force

Test-Module -Name $ModuleName 