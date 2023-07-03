
# Gets string that describes the curent module

function Get-ModuleName{
     $modulePath = $MODULE_PATH
     $moduleName = $modulePath | Split-Path -LeafBase
    return $moduleName
}

function Get-ModulePath{
    $modulePath = $PSScriptRoot | split-path -parent
    return $modulePath
}

function Get-ModuleHeader {
    $manifest = Get-ModuleManifest -Path ($PSScriptRoot | split-path -parent) 

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

