
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
    $result | Assert-AddModuleV3   
}

function TestingHelperTest_NewModuleV3_WithName_RemotePath {

    $moduleName = "MyModule"
    $folderName = "FolderName"
    $expectedPath = $folderName | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -Path $folderName

    Assert-AreEqualPath -Expected $expectedPath -Presented $result
    Assert-AddModuleV3 -Path $expectedPath 
}

function TestingHelperTest_NewModuleV3_WithOutName {

    # Error as the name is mandatory

    New-TestingFolder -Name "folderName" -PassThru | Set-Location

    $result = New-TT_ModuleV3 @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Contains -Expected "Path and Name cannot be null or empty at the same time." -Presented $errorVar.Exception.Message
}

function TestingHelperTest_NewModuleV3_AddTesting{

    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddTesting

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-AddModuleV3  -Path $modulePath 
    Assert-AddSampleCodes -Path $modulePath
    
    Assert-AddTestModuleV3 -Path $modulePath 
    Assert-AddTestSampleCodes -Path $modulePath
}

