function Get-ModuleManifestPath ($Path){
    $localPath = $Path | Convert-Path

    $Name = $localPath | Split-Path -leafbase

    $manifestPath = $Path | Join-Path -ChildPath "$Name.psd1"

    $ret =  ($manifestPath | Test-Path) ? $manifestPath : $null

    return $ret
}


function Import-ModuleManifest ($Path){

    $manifestPath = Get-ModuleManifestPath -Path $Path

    $ret = $manifestPath ? (Import-PowerShellDataFile -Path $manifestPath) : $null

    return $ret
}

# function Import-ModuleManifest ($Path){

#     $localPath = $Path | Convert-Path

#     $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue

#     if($psdpath.count -ne 1){
#         return $null
#     }
    
#     $manifest = Import-PowerShellDataFile -Path $psdpath.FullName

#     return $manifest
# }