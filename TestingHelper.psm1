
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


# function Get-PSD1{

#     $psd = Get-ChildItem -Path $PSScriptRoot -Filter *.psd1 

#     $ret = Import-PowerShellDataFile -Path $psd.FullName

#     $ret += @{ "PsdFullName" = $psd.FullName }
#     $ret += @{ "Name" = $psd.BaseName }
#     $ret += @{ "TestModuleName" = ("{0}Test" -f $psd.BaseName) }
#     $ret += @{ "TestModulePath" = ($PSScriptRoot | Join-Path -ChildPath $ret.TestModuleName) }
#     $ret += @{ "TestingFunctionPattern" = ("{0}_*" -f $ret.TestModuleName) }

#     return $ret
# } Export-ModuleMember -Function Get-PSD1

Export-ModuleMember -Function * -Alias *
