
function TestingHelperTest_NewModuleV3_AddTestingModuleV3_Simple {

    $moduleName = "MyModule"
    $folderName = "MyFolder"
    New-TestingFolder -Name $folderName
    $path = $folderName

    $param = @{
        RootModule        = "MyModuleTest.psm1"
        Author            = "Me"
        CompanyName       = "MyCompany"
        ModuleVersion     = "6.6.6"
        Description       = "MyDescription of the module"
        FunctionsToExport = @("MyFunction")
        CopyRight         = "(c) 2020 MyCompany. All rights reserved."
    } 

    $result = Add-TT_TestingModuleV3 -Name $moduleName -Path $path -Metadata $param
    
    $testingModuleName = $moduleName + "Test"
    $testingModulePath = $path | Join-Path -ChildPath $moduleName -AdditionalChildPath $testingModuleName
    
    Assert-AreEqualPath -Expected $testingModulePath -Presented $result
    Assert-AddModuleV3 -Name $testingModuleName -Path $testingModulePath -Expected $param
}

function TestingHelperTest_NewModuleV3_AddTestingModuleV3_NoParam{

    $moduleName = "MyModule"
    $testingModuleName = $moduleName + "Test"
    $testingModulePath = $moduleName | Join-Path -ChildPath $testingModuleName

    $result = Add-TT_TestingModuleV3 -Name $moduleName

    Assert-AreEqualPath -Expected $testingModulePath -Presented $result
    Assert-AddModuleV3 -Name $testingModuleName -Path $testingModulePath -Expected $param
}