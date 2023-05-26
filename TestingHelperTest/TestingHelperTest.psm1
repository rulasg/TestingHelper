
Write-Information -Message ("Loading {0} ..." -f ($PSCommandPath | Split-Path -LeafBase)) -InformationAction continue

# As we are uing TestingHelper to code and run tests of TestingHelper we need to scope 
# which functions are from the Testing version and which are from the tested version.
# We will load the tested version with a prefix. aka TT_
# On the tests functions the prefixed calls will be the actions. The rest of calls are the asserts

# Import Target Module with prefix TT_ (aka TestingTarget)
$TESTED_MANIFEST_PATH = $PSScriptRoot | split-path -Parent | Join-Path -ChildPath "TestingHelper.psd1"
$TESTED_HANDLE = Import-Module -Name $TESTED_MANIFEST_PATH -Prefix "TT_" -Force -PassThru

# Need to match the value of variable of same name of TestHelper
Set-Variable -Name TestRunFolderName -Value "TestRunFolder"
Set-Variable -Name RootTestingFolder -Value "Temp:/P"

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function "TestingHelperTest_*"