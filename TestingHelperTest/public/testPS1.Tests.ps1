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

    Remove-ImportedModule -Module "ModuleName"
}

function TestingHelperTest_TestPS1_WithPath{

    $moduleName = "ModuleName_{0}" -f (New-Guid).ToString().Substring(0,8)

    New-TT_Module -Name $moduleName -Description "description of the Module" -AddTesting

    $result = Invoke-TT_TestingHelper -Path "./$moduleName"

    Assert-AreEqual -Expected $moduleName -Presented $result.Name
    Assert-AreEqual -Expected ("{0}Test" -f $moduleName) -Presented $result.TestModule
    Assert-AreEqual -Expected ("{0}Test_*" -f $moduleName) -Presented $result.TestsName
    Assert-AreEqual -Expected 2 -Presented $result.Tests
    Assert-AreEqual -Expected 2 -Presented $result.Pass

}