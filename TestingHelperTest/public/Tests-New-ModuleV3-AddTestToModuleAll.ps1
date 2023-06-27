
function TestingHelperTest_AddTestToModuleAll_NoParam{

    $moduleName = "MyModule"
    $modulePath = New-TT_ModuleV3 -Name $moduleName

    $modulePath | Set-Location

    # Should find module on current location and add test to it
    $result = Add-TT_ToModuleTestAll

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddTestModuleV3 -Path $modulePath
}


function TestingHelperTest_AddTestToModuleAll_Simple{
    
    $moduleName = "MyModule"
    $modulePath = New-ModuleV3 -Name $moduleName

    $result = Add-TT_ToModuleTestAll -Path $modulePath

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddTestModuleV3 -Path $modulePath

}

# function TestingHelperTest_AddTestToModuleAll_WhatIf{
#     Assert-NotImplemented
# }

# function TestingHelperTest_AddTestToModuleAll_AddTestModuleV3_WhatIf{
#     Assert-NotImplemented
# }