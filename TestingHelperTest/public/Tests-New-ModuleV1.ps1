function TestingHelperTest_NewModuleV1{
    New-TT_ModuleV1 -Name "ModuleName" -Description "description of the Module"

    $psdPath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath  ModuleName.psd1
    $psmPath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath  ModuleName.psm1

    Assert-ItemExist -Path $psdPath
    Assert-ItemExist -Path $psmPath

    Assert-FileContains -Path $psdPath -Pattern "RootModule = 'ModuleName.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPath -Pattern "ModuleVersion = '0.1'" -Comment "Version"
    
    Assert-FileContains -Path $psmPath -Pattern "NAME  : ModuleName.psm1*" -Comment ".Notes Name"
    Assert-FileContains -Path $psmPath -Pattern "description of the Module" -Comment "Description"

    # Test module
    $ps1PathTest = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest.ps1
    $psdPathTest = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest , ModuleNameTest.psd1
    $psmPathTest = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest , ModuleNameTest.psm1

    Assert-ItemExist -Path $ps1PathTest
    Assert-ItemExist -Path $psdPathTest
    Assert-ItemExist -Path $psmPathTest

    Assert-FileContains -Path $psdPathTest -Pattern "RootModule = 'ModuleNameTest.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPathTest -Pattern "ModuleVersion = '0.1'"
    
    Assert-FileContains -Path $psmPathTest -Pattern "function ModuleNameTest_Sample()" -Comment "Function header"
    Assert-FileContains -Path $psmPathTest -Pattern "Export-ModuleMember -Function ModuleNameTest_*" -Comment "Export"

    #vscode/Launch.json
    $launchFile = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ".vscode" , "launch.json"

    Assert-ItemExist -Path $launchFile -Comment "launch.json exists"
    $json = Get-Content -Path $launchFile | ConvertFrom-Json

    Assert-IsTrue -Condition ($json.configurations.Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations.Script -eq '${workspaceFolder}/ModuleNameTest.ps1')
    Assert-IsTrue -Condition ($json.configurations.cwd -eq '${workspaceFolder}')
    Assert-IsTrue -Condition ($json.configurations.type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations.name -like '*ModuleName.ps1')
}

function TestingHelperTest_NewTestingModule{
    New-TT_TestingModule -ModuleName "ModuleName" -Path .

    $psdPathTest = Join-Path -Path . -ChildPath ModuleNameTest -AdditionalChildPath  ModuleNameTest.psd1
    $psmPathTest = Join-Path -Path . -ChildPath ModuleNameTest -AdditionalChildPath  ModuleNameTest.psm1

    Assert-ItemExist -Path "ModuleNameTest.ps1"
    Assert-ItemExist -Path $psdPathTest
    Assert-ItemExist -Path $psmPathTest

    Assert-FileContains -Path $psdPathTest -Pattern "RootModule = 'ModuleNameTest.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPathTest -Pattern "ModuleVersion = '0.1'"
    
    Assert-FileContains -Path $psmPathTest -Pattern "function ModuleNameTest_Sample()" -Comment "Function header"
    Assert-FileContains -Path $psmPathTest -Pattern "Export-ModuleMember -Function ModuleNameTest_*" -Comment "Export"
}

function TestingHelperTest_NewTestingVsCodeLaunchJson{
    New-TT_TestingVsCodeLaunchJson -Path . -ModuleName "ModuleName"

    $launchFile = Join-Path -Path . -ChildPath ".vscode" -AdditionalChildPath "launch.json"

    Assert-ItemExist -Path $launchFile -Comment "launch.json exists"
    $json = Get-Content -Path $launchFile | ConvertFrom-Json

    Assert-IsTrue -Condition ($json.configurations.Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations.Script -eq '${workspaceFolder}/ModuleNameTest.ps1')
    Assert-IsTrue -Condition ($json.configurations.cwd -eq '${workspaceFolder}')
    Assert-IsTrue -Condition ($json.configurations.type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations.name -like '*ModuleName.ps1')
}