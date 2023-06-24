function Get-DefaultsManifest {
    New-ModuleManifest -Path defaults.psd1 -RootModule defaults.psm1
    $defaultsManifest = Import-PowerShellDataFile -Path defaults.psd1 
    return $defaultsManifest
}



function Assert-TestingV3 {
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path,
        [Parameter()][hashtable]$Expected
    )

    Assert-AddTestingV3 -Path $Path -Expected $Expected

}

