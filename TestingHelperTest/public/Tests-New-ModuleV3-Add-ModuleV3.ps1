

function TestingHelperTest_NewModuleV3_WithName {

    $moduleName = "MyModule"

    $result = New-TT_ModuleV3 -Name $moduleName

    Assert-AreEqualPath -Expected $moduleName -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $moduleName 
}

function TestingHelperTest_NewModuleV3_WithNameRemotePath {

    $moduleName = "MyModule"
    $folderName = "FolderName"
    $expectedPath = $folderName | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -Path $folderName

    Assert-AreEqualPath -Expected $expectedPath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $expectedPath 
}

function TestingHelperTest_NewModuleV3_WithOutName {

    # Figure out the Name from folder Name and path

    New-TestingFolder -Name "folderName" -PassThru | Set-Location
    $localPath = Get-Location | Convert-Path

    $result = New-TT_ModuleV3 @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Contains -Expected "Path and Name cannot be null or empty at the same time." -Presented $errorVar.Exception.Message
}

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

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_Simple{

    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-TestingV3 -Name $moduleName -Path $modulePath
}

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_AddSampleCode{

    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting -AddSampleCode

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddSampleCode
    Assert-TestingV3 -Name $moduleName -Path $modulePath -AddSampleCode
}

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_AddDevcontainerjson{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddDevContainerJson

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddDevContainerJson
}

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_AddLICENSE{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddLicense

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddLicense
}

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_AddReadme{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddReadme

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddReadme
}

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_AddReadme_WithDescription{
    
    $myDescription = "This is my Description"
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddReadme -Description $myDescription

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    $readMePath = $modulePath | Join-Path -ChildPath "README.md"
    Assert-IsTrue -Condition ((Get-Content -Path $readMePath) -contains $myDescription)
}

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_AddAbout{
    
    $myDescription = "This is my Description"
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $param = @{
        Description = "This is my Description"
        Author = "Me"
    }

    $result = New-TT_ModuleV3 -Name $moduleName -AddAbout @param

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    $moduleMonifest = Import-PowerShellDataFile -path ($modulePath | Join-Path -ChildPath "$moduleName.psd1" )
    Assert-AreEqual -Expected $param.Description -Presented $moduleMonifest.Description
    Assert-AreEqual -Expected $param.Author -Presented $moduleMonifest.Author
    
    $aboutContent = Get-Content -Path ($modulePath | Join-Path -ChildPath "en-US" -AdditionalChildPath "about_MyModule.help.txt") | Out-String
    Assert-IsTrue -Condition ($aboutContent.Contains("about_$moduleName"))
    Assert-IsTrue -Condition ($aboutContent.Contains($moduleMonifest.Author))
    Assert-IsTrue -Condition ($aboutContent.Contains($moduleMonifest.Description))
    Assert-IsTrue -Condition ($aboutContent.Contains($moduleMonifest.CopyRight))
    Assert-IsTrue -Condition ($aboutContent.Contains("Powershell Testing UnitTest Module TestingHelper"))
}