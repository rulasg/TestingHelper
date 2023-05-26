
# return the manifest of the tested module
function Get-TestedModuleManifestPath{

    $localPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Convert-Path

    $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue

    if($psdpath.count -ne 1){
        throw "No psd1 file found in path $localPath"
    }

    return $psdpath.FullName
}

function Get-TestedModuleManifest{
    $manifestPath = Get-TestedModuleManifestPath
    $manifest = Import-PowerShellDataFile -Path $manifestPath

    $manifest.PsdPath = $manifestPath
    $manifest.Name = $manifest.RootModule | Split-Path -leafbase

    return $manifest
}

# return handle of the tested module
function Get-TestedModuleHandle{
    Get-TestedModuleManifestPath |  Import-Module -PassThru
} Export-ModuleMember -Function Get-TestedModuleHandle