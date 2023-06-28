function TestingHelperTest_NewModuleV2{
    #
    New-TT_Modulev2 -Name "ModuleName" -Description "description of the Module" -Version "9.9.9" -WarningAction SilentlyContinue # Supress Obsolete Warning

    #PSD1
    $psdPath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath  ModuleName.psd1
    Assert-ItemExist -Path $psdPath
    Assert-FileContains -Path $psdPath -Pattern "RootModule = 'ModuleName.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPath -Pattern "ModuleVersion = '9.9.9'" -Comment "Version"
    
    #PSM1
    $psmPath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath  ModuleName.psm1
    Assert-ItemExist -Path $psmPath

    # Test module
    $testModulePath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest
    
    ## Testing PSD1
    $psdPathTest = $testModulePath | Join-Path -ChildPath ModuleNameTest.psd1
    Assert-ItemExist -Path $psdPathTest
    Assert-FileContains -Path $psdPathTest -Pattern "RootModule = 'ModuleNameTest.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPathTest -Pattern "ModuleVersion = '9.9.9'"
    
    ## Testing PSM1
    $psmPathTest = $testModulePath | Join-Path -ChildPath ModuleNameTest.psm1
    Assert-ItemExist -Path $psmPathTest -Comment "psm1 does not exist"
    
    ## Testing Sample
    $samplePublicPath = $testModulePath | Join-Path -ChildPath "public" -AdditionalChildPath SampleFunctionTests.ps1
    Assert-ItemExist -Path $samplePublicPath
    Assert-FileContains -Path $samplePublicPath -Pattern "ModuleNameTest_GetPrivateString()" -Comment "Function header"
    Assert-FileContains -Path $samplePublicPath -Pattern "ModuleNameTest_GetPublicString()" -Comment "Function header"
    Assert-FileContains -Path $samplePublicPath -Pattern "Export-ModuleMember -Function ModuleNameTest_*" -Comment "Export"

    #vscode/Launch.json
    $launchFile = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ".vscode" , "launch.json"

    Assert-ItemExist -Path $launchFile -Comment "launch.json exists"
    $json = Get-Content -Path $launchFile | ConvertFrom-Json

    Assert-IsTrue -Condition ($json.configurations[0].name -eq 'PowerShell: Run Test')
    Assert-IsTrue -Condition ($json.configurations[0].type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations[0].Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations[0].Script -eq '${workspaceFolder}/test.ps1')
    Assert-IsTrue -Condition ($json.configurations[0].cwd -eq '${workspaceFolder}')

    Assert-IsTrue -Condition ($json.configurations[1].name -eq 'PowerShell Interactive Session')
    Assert-IsTrue -Condition ($json.configurations[1].type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations[1].Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations[1].cwd -eq '')
}


function TestingHelperTest_NewModuleV2_RunModuleTest_RunFromAnyLocation_AnyName{
    # We will be running the test.ps1 uing the testing TestingHlper and not the tested TestingHelper that created the module.

    $ModuleName = "ModuleName_{0}" -f (New-Guid).ToString().Substring(0,8)
    
    New-TT_Modulev2 -Name $ModuleName -Description "description of the Module" -Version "9.9.9" -WarningAction SilentlyContinue # Supress Obsolete Warning 

    $test = $ModuleName | Join-Path -ChildPath "test.ps1" | Resolve-Path

    # Add prefix to call the script calling commandlet to call the tested version of TestingHelper
    (Get-Content -Path $test) -replace "Invoke-TestingHelper","Invoke-TT_TestingHelper" | Set-Content -Path $test

    # mode to a different random folder
    New-TestingFolder -PassThru | Set-Location

    # Run the test.ps1 from random folder
    $testnewPath = Join-Path -Path ".." -ChildPath $ModuleName -AdditionalChildPath "test.ps1"
    $result = & $testnewPath

    # Assert-AreEqual -Expected ModuleName -Presented $result.Name
    Assert-AreEqual -Expected ($ModuleName+"Test") -Presented $result.TestModule
    Assert-AreEqual -Expected 2 -Presented $result.Pass
    Assert-AreEqual -Expected 2 -Presented $result.Tests
}