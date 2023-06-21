
function TestingHelperTest_NewModuleV3_AddTestingToModule_AddTestingModuleV3_Simple {

    $moduleName = "MyModule"
    $folderName = "MyFolder"
    New-TestingFolder -Name $folderName
    $modulePath = $folderName

    $param = @{
        RootModule        = "MyModuleTest.psm1"
        Author            = "Me"
        CompanyName       = "MyCompany"
        ModuleVersion     = "6.6.6"
        Description       = "MyDescription of the module"
        FunctionsToExport = @("MyFunction")
        CopyRight         = "(c) 2020 MyCompany. All rights reserved."
    } 

    $result = Add-TT_TestingToModuleV3 -Name $moduleName -Path $modulePath -Metadata $param
    
    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-TestingV3 -Name $moduleName -Path $modulePath -Expected $param
}

function TestingHelperTest_NewModuleV3_AddTestingToModule_AddTestingModuleV3_NoParam{

    $moduleName = "MyModule"
    $modulePath = '.' | Join-Path -ChildPath $moduleName
    $testingModuleName = $moduleName + "Test"
    $testingModulePath = $modulePath | Join-Path -ChildPath $testingModuleName

    $result = Add-TT_TestingToModuleV3 -Name $moduleName -Path $modulePath
 
    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-TestingV3 -Name $moduleName -Path $modulePath -Expected $param
}


function TestingHelperTest_NewModuleV3_AddTestingToModule_Simple{
    
    $moduleName = "MyModule"
    $path = "."
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = Add-TT_TestingToModuleV3 -Name $moduleName -Path $modulePath

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-TestingV3 -Name $moduleName -Path $modulePath -Expected $param

}

function TestingHelperTest_NewModuleV3_AddTestingToModule_WhatIf{
    Assert-NotImplemented
}

function TestingHelperTest_NewModuleV3_AddTestingToModule_AddTestModuleV3_WhatIf{
    Assert-NotImplemented
}