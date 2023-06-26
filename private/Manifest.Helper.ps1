
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

function Get-ModuleManifestPath ($Path){
    $localPath = $Path | Convert-Path

    $Name = $localPath | Split-Path -leafbase

    $manifestPath = $Path | Join-Path -ChildPath "$Name.psd1"

    $ret =  ($manifestPath | Test-Path) ? $manifestPath : $null

    return $ret
}

# returns the manifest of the testing module of the module on Path
function Get-TestingModuleManifest($ModulePath){

    $name = $ModulePath | Split-Path -leafbase
    $testingModulename = Get-TestingModuleName -TargetModule $name
    $testingpath = $ModulePath | Join-Path -ChildPath $testingModulename

    $ret = Get-ModuleManifest -Path $testingpath

    return $ret
}