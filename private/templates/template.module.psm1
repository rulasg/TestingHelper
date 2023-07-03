Write-Information -Message ("Loading {0} ..." -f ($PSCommandPath | Split-Path -LeafBase)) -InformationAction continue

#Module path is where resides the RootModule file. This file. :)
$MODULE_PATH = $PSScriptRoot

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $MODULE_PATH\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $MODULE_PATH\private\*.ps1 -ErrorAction SilentlyContinue )

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

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

