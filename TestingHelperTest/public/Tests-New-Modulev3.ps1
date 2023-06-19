

function TestingHelperTest_NewModuleV3_WithName {

    $moduleName = "MyModule"

    $result = New-TT_ModuleV3 -Name $moduleName

    Assert-AddModuleV3 -Name $moduleName -Path $result 

}

function TestingHelperTest_NewModuleV3_WithOutName {

    $result = New-TT_ModuleV3

    Assert-IsNull -Object $result

    $dirContent = Get-ChildItem

    Assert-Count -Expected 0 -Presented $dirContent

}

function TestingHelperTest_NewModuleV3_AddModule_FailCall_NewModuleManifest {

    # test when failing calling dependency Microsoft.PowerShell.Core/New-ModuleManifest

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

    $result = Add-LL_ModuleV3 -Name "MyModule" @ErrorParameters

    Assert-IsNull -Object $result -Comment "No module is created"
    Assert-Contains -Expected "Injected error from New-MymoduleManifest." -Presented ($errorVar.Exception.Message)

    # reset module
    Import-Module -Name $TESTED_MANIFEST_PATH -Prefix "TT_" -Force
}
function TestingHelperTest_NewModuleV3_AddModule_DefaultManifest {

    $moduleName = "MyModule"

    $result = Add-TT_ModuleV3 -Name $moduleName -Path '.'

    $defaultsManifest = Get-DefaultsManifest

    Assert-AddModuleV3 -Name $moduleName -Path $result -Expected $defaultsManifest

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
    
    $result = Add-TT_ModuleV3 -Name $moduleName -Path '.' -Metadata $param

    Assert-AddModuleV3 -Name $moduleName -Path $result -Expected $param

}

function TestingHelperTest_NewModuleV3_AddModule_PathAlreadyExists {

    "MyModule" | New-TestingFolder 

    $result = Add-TT_ModuleV3 -Name "MyModule" -Path '.' @ErrorParameters
    
    Assert-IsNull -Object $result -Comment "No module is created"
    Assert-Count -Expected 1 -Presented $errorVar -Comment "One error is thrown"
    Assert-Contains -Expected "Path already exists." -Presented ($errorVar.Exception.Message)
}

function TestingHelperTest_NewModuleV3_AddModule_WrongPathName {
    
    $result = Add-TT_ModuleV3 -Name "MyModule" -Path 'WrongName_"*?"like' @ErrorParameters

    Assert-IsNull -Object $result -Comment "No module is created"
    Assert-ContainsPattern -Expected "Error creating the PSD1 file.*" -Presented ($errorVar.Exception.Message)
}

function Get-DefaultsManifest {
    New-ModuleManifest -Path defaults.psd1 -RootModule defaults.psm1
    $defaultsManifest = Import-PowerShellDataFile -Path defaults.psd1 
    return $defaultsManifest
}
function Assert-AddModuleV3 {
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path,
        [Parameter()][hashtable]$Expected
    )
    
    $psdname = $Name + ".psd1"
    $psmName = $Name + ".psm1"

    $fullExpected = Get-DefaultsManifest
    
    # Update fullExpected with expected
    ForEach($key in $Expected.Keys) { $fullExpected[$key] = $Expected[$key]}

    #PSD1
    $psdPath = $Path | Join-Path -ChildPath  $psdname
    Assert-ItemExist -Path $psdPath

    #PSM1
    $psmPath = $Path | Join-Path -ChildPath $psmName
    Assert-ItemExist -Path $psmPath

    #manifest
    $presented = Import-PowerShellDataFile -Path $psdPath

    # GUID
    # PrivateData
    Assert-AreEqual -Expected $fullExpected.AliasesToExport   -Presented $presented.AliasesToExport   -Comment "Manifest AliasesToExport"
    Assert-AreEqual -Expected $fullExpected.Author            -Presented $presented.Author            -Comment "Manifest Author"
    Assert-AreEqual -Expected $fullExpected.CmdletsToExport   -Presented $presented.CmdletsToExport   -Comment "Manifest CmdletsToExport"
    Assert-AreEqual -Expected $fullExpected.VariablesToExport -Presented $presented.VariablesToExport -Comment "Manifest VariablesToExport"
    Assert-AreEqual -Expected $fullExpected.ModuleVersion     -Presented $presented.ModuleVersion     -Comment "Manifest ModuleVersion"
    Assert-AreEqual -Expected $fullExpected.Copyright         -Presented $presented.Copyright         -Comment "Manifest Copyright"
    Assert-AreEqual -Expected $fullExpected.CompanyName       -Presented $presented.CompanyName       -Comment "Manifest CompanyName"
    
    # Not Strings
    Assert-AreEqual -Expected ($fullExpected.FunctionsToExport | ConvertTo-Json) -Presented ($presented.FunctionsToExport | ConvertTo-Json) -Comment "Manifest FunctionsToExport"

    #Exceptions
    Assert-AreEqual -Expected "$Name.psm1" -Presented $presented.RootModule -Comment "Manifest RootModule"
    Assert-AreEqual -Expected ($fullExpected.Description ?? "") -Presented ($presented.Description ?? "") -Comment "Manifest Description"

    Write-AssertionSectionEnd
}
