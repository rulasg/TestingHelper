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