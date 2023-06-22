
function GetExpectedHeader{
    $tedmanifest = Get-TestedModuleManifest
    $expected = "{0} v{1} {2}" -f $tedmanifest.Name, $tedmanifest.ModuleVersion, $tedmanifest.PrivateData.PSData.Prerelease

    return $expected
}

function TestingHelperTest_GetModuleHeader {
    $module = Get-TestedModuleHandle
        
    $result = & $module {
        Get-ModuleHeader
    }

    Assert-AreEqual -Expected (GetExpectedHeader) -Presented $result
}

function TestingHelperTest_TestPS1{

    New-TT_Module -Name "ModuleName" -Description "description of the Module" -AddTesting

    $test = "ModuleName" | Join-Path -ChildPath "test.ps1" | Resolve-Path

    # Add prefix to call the script calling commandlet to call the tested version of TestingHelper
    (Get-Content -Path $test) -replace "Invoke-TestingHelper","Invoke-TT_TestingHelper" | Set-Content -Path $test

    # Run the test.ps1 
    $result = & $test @InfoParameters

    Assert-AreEqual -Expected "ModuleName" -Presented $result.Name
    Assert-AreEqual -Expected "ModuleNameTest" -Presented $result.TestModule
    Assert-AreEqual -Expected "ModuleNameTest_*" -Presented $result.TestsName
}

function TestingHelperTest_TestPS1_WithPath{

    New-TT_Module -Name "ModuleName" -Description "description of the Module" -AddTesting

    $result = Invoke-TT_TestingHelper -Path "./ModuleName"

    Assert-AreEqual -Expected "ModuleName" -Presented $result.Name
    Assert-AreEqual -Expected "ModuleNameTest" -Presented $result.TestModule
    Assert-AreEqual -Expected "ModuleNameTest_*" -Presented $result.TestsName
}

# Testing TestingHelperTest private function Get-TestedModuleHandle
function TestingHelperTest_GetModuleHandle {
    
    $localPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
    $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue
    $manifest = Import-PowerShellDataFile -Path $psdpath

    # Internal TestingHelperTest function
    $result = Get-TestedModuleHandle

    Assert-IsNotNull -Object $result
    Assert-AreEqual -Expected ($manifest.RootModule | Split-Path -LeafBase) -Presented $result.Name
    Assert-AreEqual -Expected $manifest.ModuleVersion -Presented $result.Version
    if ($manifest.PrivateData.PSData.Prerelease) {
        Assert-AreEqual -Expected $manifest.PrivateData.PSData.Prerelease -Presented $result.PrivateData.PSData.Prerelease
    } else {
        Assert-IsNull -Object $h.PrivateData.PSData.Prerelease
    }
 }