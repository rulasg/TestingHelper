
function GetExpectedHeader{
    $tedmanifest = Get-TestingHelperTestedModuleManifest
    $expected = "{0} v{1} {2}" -f $tedmanifest.Name, $tedmanifest.ModuleVersion, $tedmanifest.PrivateData.PSData.Prerelease

    return $expected
}

function TestingHelperTest_GetModuleHeader {
    $module = Get-TestingHelperTestedModuleHandle
        
    $result = & $module {
        Get-ModuleHeader
    }

    Assert-AreEqual -Expected (GetExpectedHeader) -Presented $result
}

# Testing TestingHelperTest private function Get-TestingHelperTestedModuleHandle
function TestingHelperTest_GetModuleHandle {
    
    $localPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue
    $manifest = Import-PowerShellDataFile -Path $psdpath

    # Internal TestingHelperTest function
    $result = Get-TestingHelperTestedModuleHandle

    Assert-IsNotNull -Object $result
    Assert-AreEqual -Expected ($manifest.RootModule | Split-Path -LeafBase) -Presented $result.Name
    Assert-AreEqual -Expected $manifest.ModuleVersion -Presented $result.Version
    if ($manifest.PrivateData.PSData.Prerelease) {
        Assert-AreEqual -Expected $manifest.PrivateData.PSData.Prerelease -Presented $result.PrivateData.PSData.Prerelease
    } else {
        Assert-IsNull -Object $h.PrivateData.PSData.Prerelease
    }
 }