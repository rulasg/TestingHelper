
function TestingHelperTest_NewModule_UseAlias{
    
    $result = Get-Command -Name New-TT_Module -Module TestingHelper
    
    Assert-AreEqual -Expected "Alias" -Presented $result.CommandType
    Assert-AreEqual -Expected "New-TT_ModuleV3" -Presented $result.Definition
    Assert-AreEqual -Expected "TestingHelper" -Presented $result.ModuleName
}

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

function TestingHelperTest_NewModuleV3_AddTestingToModuleV3_Simple{

    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-TestingV3 -Name $moduleName -Path $modulePath
}

function TestingHelperTest_NewModuleV3_AddModuleV3_AddTestingToModuleV3_AddSampleCode{

    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting -AddSampleCode

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddSampleCode
    Assert-TestingV3 -Name $moduleName -Path $modulePath -AddSampleCode
}

function TestingHelperTest_NewModuleV3_AddDevcontainerjson{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddDevContainerJson

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddDevContainerJson
}

function TestingHelperTest_NewModuleV3_AddLICENSE{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddLicense

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddLicense
}

function TestingHelperTest_NewModuleV3_AddReadme{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddReadme

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddReadme
}

function TestingHelperTest_NewModuleV3_AddReadme_WithDescription{
    
    $myDescription = "This is my Description"
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddReadme -Description $myDescription

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    $readMePath = $modulePath | Join-Path -ChildPath "README.md"
    Assert-IsTrue -Condition ((Get-Content -Path $readMePath) -contains $myDescription)
}

function TestingHelperTest_NewModuleV3_AddAbout{
    
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

function TestingHelperTest_NewModuleV33_AddDeployScript{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddDeployScript

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddDeployScript
}

function TestingHelperTest_NewModuleV3_AddReleaseScript{
    
    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddReleaseScript

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddReleaseScript
}

function TestingHelperTest_NewModuleV3_AddSyncScript{
    
    $moduleName = "MyModule"
    $modulePath = '.' | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddSyncScript

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddSyncScript
}

function TestingHelperTest_NewModuleV3_AddPSScriptAnalyzer {
    
    $moduleName = "MyModule"
    $modulePath = '.' | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddPSScriptAnalyzerWorkflow

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddPSScriptAnalyzerWorkflow
}

function TestingHelperTest_NewModuleV3_AddTestingWorkflow {
    
    $moduleName = "MyModule"
    $modulePath = '.' | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddTestingWorkflow

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddTestingWorkflow
}

function TestingHelperTest_NewModuleV3_AddDeployWorkflow {
    
    $moduleName = "MyModule"
    $modulePath = '.' | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddDeployWorkflow

    Assert-AreEqualPath -Expected $modulePath -Presented $result
    Assert-AddModuleV3 -Name $moduleName -Path $modulePath -AddDeployWorkflow
}