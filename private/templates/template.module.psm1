<#
.SYNOPSIS
    RootModule of the module V2 TestingHelper framework.
.DESCRIPTION
    This is the RootModule of a library that will load the module code from .ps1 files presented on public and private folders
    This structure allows to split the code of a module on different files allowing a better maintenance and collaborative development.
    Check rulasg/DemoPsModule as a module smaple or rulasg/TestingHelper as the helper of this framework.
.LINK
    https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.module.psm1
#>


#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try { . $import.fullname }
    Catch { Write-Error -Message "Failed to import function $($import.fullname): $_" }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only