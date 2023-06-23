
function TestingHelperTest_AddModuleSection_PipeCalls{
    $modulePath = New-ModuleV3 -Name "module1"

    $modulePath | Add-TT_ModuleLicense

    Assert-AddModuleV3 -Name "module1" -Path $modulePath -AddLicense
}