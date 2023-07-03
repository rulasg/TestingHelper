
# Gets string that describes the curent module

function Get-ModuleHeader {
    $manifest = Get-ModuleManifest -Path $MODULE_PATH

    $header = "{0} v{1} {2}" -f $manifest.Name, $manifest.ModuleVersion, $manifest.PrivateData.PSData.Prerelease

    return $header

}

function Get-TestingModuleName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)] [string] $TargetModule
    )
    
    return ($TargetModule + "Test") 
} 

