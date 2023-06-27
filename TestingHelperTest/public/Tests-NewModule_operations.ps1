
function TestingHelperTest_Manual_Work_StepsToFull{

    $path = '.' | Join-Path -ChildPath "ModuleName"
    
    # Create module
    $null = Add-TT_ModuleV3 -Name "ModuleName"
    $modulePath = $path | Resolve-Path
    Assert-AddModuleV3 -Path $modulePath

    # Move to module path to call add functions with no parameters
    Push-Location $modulePath

    # Add Sample code on local folder
    Add-TT_ToModuleSampleCode
    Assert-AddSampleCodes -Path $modulePath
    
    # Add Testing to module
    Add-TT_ToModuleTestModule
    Assert-AddTestModuleV3 -Path $modulePath 

    # Add Test Sample code
    Add-TT_ToModuleTestSampleCode
    Assert-AddTestSampleCodes -Path $modulePath

    Pop-Location

    # Run tests
    
    $result = Invoke-TT_TestingHelper -Path $modulePath

    Assert-AreEqual -Expected 2 -Presented $result.Tests
    Assert-AreEqual -Expected 2 -Presented $result.Pass
}

function TestingHelperTest_Manual_Work_Testing{
    $path = '.' | Join-Path -ChildPath "ModuleName"
    
    # Create module
    $null = Add-TT_ModuleV3 -Name "ModuleName"
    $modulePath = $path | Resolve-Path
    Assert-AddModuleV3 -Path $modulePath

    # Move to module path to call add functions with no parameters
    Push-Location $modulePath

    Add-TT_ToModuleAll
    Assert-AddAll -Path $modulePath

    Pop-Location

    # Run tests
    
    $result = Invoke-TT_TestingHelper -Path $modulePath

    Assert-AreEqual -Expected 2 -Presented $result.Tests
    Assert-AreEqual -Expected 2 -Presented $result.Pass
}