
function TestingHelperTest_NewModuleV3_AddModule_FailCall_NewModuleManifest {

    # test when failing calling dependency Microsoft PowerShell.Core/New-ModuleManifest

    $modulename = "MyModule"
    
    # Inject depepdency
    $module = Import-Module -Name $TESTED_MANIFEST_PATH -Prefix "LL_" -Force -PassThru
    & $module {
        . {
            function script:New-MyModuleManifest {
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory)][string]$Path,
                    [Parameter(Mandatory)][string]$RootModule
                )
                throw "Injected error from New-MymoduleManifest."
            }
        }
    }

    $result = Add-LL_ModuleV3 -Name $modulename  @ErrorParameters

    Assert-IsNull -Object $result -Comment "No module is created"
    Assert-IsNotNull -Object $errorVar.Exception -Comment "Error is thrown"
    Assert-Contains -Expected "Injected error from New-MymoduleManifest." -Presented ($errorVar.Exception.Message)
    Assert-ContainsPattern -Expected "Error creating the PSD1 file.*" -Presented ($errorVar.Exception.Message)

    # reset module
    Import-Module -Name $TESTED_MANIFEST_PATH -Prefix "TT_" -Force
}

function TestingHelperTest_NewModuleV3_AddModule_DefaultManifest {

    $moduleName = "MyModule"

    $result = Add-TT_ModuleV3 -Name $moduleName

    $defaultsManifest = Get-DefaultsManifest

    Assert-AreEqualPath -Expected $moduleName -Presented $result

    Assert-AddModuleV3 -Name $moduleName -Path $moduleName -Expected $defaultsManifest
}

function TestingHelperTest_NewModuleV3_AddModule_MyManifest {

    $moduleName = "MyModule"

    $param = @{
        RootModule        = "MyModule.psm1"
        Author            = "Me"
        CompanyName       = "MyCompany"
        ModuleVersion     = "6.6.6"
        Description       = "MyDescription of the module"
        FunctionsToExport = @("MyFunction")
        CopyRight         = "(c) 2020 MyCompany. All rights reserved."
    } 
    
    $result = Add-TT_ModuleV3 -Name $moduleName -Metadata $param

    Assert-AddModuleV3 -Name $moduleName -Path $result -Expected $param

}

