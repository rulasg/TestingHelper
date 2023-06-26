function Get-DefaultsManifest {
    New-ModuleManifest -Path defaults.psd1 -RootModule defaults.psm1
    $defaultsManifest = Import-PowerShellDataFile -Path defaults.psd1 
    Remove-Item defaults.psd1
    return $defaultsManifest
}



function Assert-TestModuleV3 {
    param(
        [Parameter()][string]$Path,
        [Parameter()][hashtable]$Expected
    )

    Assert-AddTestV3 -Path $Path -Expected $Expected

}

