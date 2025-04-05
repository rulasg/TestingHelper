
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

function TestingHelperTest_Manual_Work_Testing_2{

    $moduleName = "modulename_{0}" -f (New-Guid).ToString().Substring(0,8)

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting

    $result = Invoke-TT_TestingHelper -Path $result
    Assert-AreEqual -Expected 2 -Presented $result.Tests
    Assert-AreEqual -Expected 2 -Presented $result.Pass
}

function TestingHelperTest_Manual_Work_Testing_3{

    $moduleName = "modulename_{0}" -f (New-Guid).ToString().Substring(0,8)

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting

    $newName = rename-item -Path $result -NewName "NewName" -PassThru

    $result = Invoke-TT_TestingHelper -Path $newName
    Assert-AreEqual -Expected 2 -Presented $result.Tests
    Assert-AreEqual -Expected 2 -Presented $result.Pass
}

function TestingHelperTest_Manual_Work_Testing_WithBeforeAndAfter{

    $moduleName = "modulename_{0}" -f (New-Guid).ToString().Substring(0,8)

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting
    $func =@'

    $global:RunBeforeEach_Count = 0
    $global:RunAfterEach_Count = 0
    $global:RunBeforeAll = $false
    $global:RunAfterAll = $false

    function Run_BeforeAll{
        Assert-IsTrue -Condition $true
        $global:RunBeforeAll = $true
    }
    
    function Run_AfterAll{
        Assert-IsTrue -Condition $true
        $global:RunAfterAll = $true
    }

    function Run_BeforeEach{
        Assert-IsTrue -Condition $true
        $global:RunBeforeEach_Count++
    }

    function Run_AfterEach{
        Assert-IsTrue -Condition $true
        $global:RunAfterEach_Count++
    }

    Export-ModuleMember -Function Run_*
'@

    # Create BeforeAndAfter.ps1
    New-TestingFile -Path "$moduleName/Test/public" -Name "BeforeAndAfter.ps1" -Content $func

    # Act

    $result = Invoke-TT_TestingHelper -Path $result

    # Assert
    Assert-AreEqual -Expected 2 -Presented $result.Tests
    Assert-AreEqual -Expected 2 -Presented $result.Pass

    Assert-IsTrue -Condition $result.RunAfterAll
    Assert-IsTrue -Condition $result.RunAfterAll

    Assert-IsTrue -Condition $global:RunBeforeAll
    Assert-IsTrue -Condition $global:RunAfterAll

    Assert-AreEqual -Expected 2 -Presented $global:RunBeforeEach_Count
    Assert-AreEqual -Expected 2 -Presented $global:RunAfterEach_Count

    $global:RunBeforeEach_Count = $null
    $global:RunAfterEach_Count = $null
    $global:RunBeforeAll = $null
    $global:RunAfterAll = $null
}