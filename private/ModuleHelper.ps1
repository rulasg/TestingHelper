
# Gets string that describes the curent module
function Get-ModuleHeader {
    $manifest = Get-ModuleManifest -Path ($PSScriptRoot | split-path -parent) 

    $header = "{0} v{1} {2}" -f $manifest.Name, $manifest.ModuleVersion, $manifest.PrivateData.PSData.Prerelease

    return $header

}

# return the manifest on path
function Get-ModuleManifest($Path){

    $localPath = $Path | Convert-Path

    $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue

    if($psdpath.count -ne 1){
        throw "No psd1 file found in path $localPath"
    }
    
    $manifest = Import-PowerShellDataFile -Path $psdpath.FullName

    $manifest.Path = $localPath
    $manifest.PsdPath = $psdpath.FullName
    $manifest.Name = $manifest.RootModule | Split-Path -leafbase

    return $manifest
}

# returns the manifest of the testing module of the module on Path
function Get-TestingModuleManifest($ModulePath){

    $name = $ModulePath | Split-Path -leafbase
    $testingModulename = Get-TestingModuleName -TargetModule $name
    $testingpath = $ModulePath | Join-Path -ChildPath $testingModulename

    $ret = Get-ModuleManifest -Path $testingpath

    return $ret
}