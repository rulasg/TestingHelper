
function GetExpectedHeader{
    $tedmanifest = Get-TestedModuleManifest
    $expected = "{0} v{1} {2}" -f $tedmanifest.Name, $tedmanifest.ModuleVersion, $tedmanifest.PrivateData.PSData.Prerelease

    return $expected
}

function TestingHelperTest_GetModuleHeader {
    $module = Get-ModuleHandle
        
    $result = & $module {
        Get-ModuleHeader
    }

    Assert-AreEqual -Expected (GetExpectedHeader) -Presented $result
}

function TestingHelperTest_AddModuleHeaderToTest{

    New-TT_Modulev2 -Name "ModuleName" -Description "description of the Module" -Version "9.9.9"

    $test = "ModuleName" | Join-Path -ChildPath "test.ps1" | Resolve-Path

    # Add prefix to call the script calling commandlet to call the tested version of TestingHelper
    (Get-Content -Path $test) -replace "Test-ModulelocalPSD1","Test-TT_ModulelocalPSD1" | Set-Content -Path $test

    # Run the test.ps1 
    $null = & $test @InfoParameters

    Assert-AreEqual -Expected (GetExpectedHeader) -Presented $infoVar[0]
}

# Testing TestingHelperTest private function Get-ModuleHandle
function TestingHelperTest_GetModuleHandle {
    $localPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue
    $manifest = Import-PowerShellDataFile -Path $psdpath

    # Internal TestingHelperTest function
    $result = Get-ModuleHandle

    Assert-IsNotNull -Object $result
    Assert-AreEqual -Expected ($manifest.RootModule | Split-Path -LeafBase) -Presented $result.Name
    Assert-AreEqual -Expected $manifest.ModuleVersion -Presented $result.Version
    if ($manifest.PrivateData.PSData.Prerelease) {
        Assert-AreEqual -Expected $manifest.PrivateData.PSData.Prerelease -Presented $result.PrivateData.PSData.Prerelease
    } else {
        Assert-IsNull -Object $h.PrivateData.PSData.Prerelease
    }
    
 }