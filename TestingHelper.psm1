Write-Information -Message ("Loading {0} ..." -f ($PSCommandPath | Split-Path -LeafBase)) -InformationAction continue


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

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

# Export-ModuleMember -Function * -Alias *

# TODO : Reduce the number of functions exported
Export-ModuleMember -Function Assert-*
Export-ModuleMember -Function New-Testing*
Export-ModuleMember -Function Test-Module*
