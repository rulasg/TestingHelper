
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

function TestingHelperTest_NewModuleV3_WithOutName_LocalPath {

    # Error as the name is mandatory

    $folder = New-TestingFolder -Name "ModulefolderName" -PassThru
    Set-Location -Path $folder

    $result = New-TT_ModuleV3 @ErrorParameters

    Assert-IsNull -Object $result
    Assert-Contains -Expected "Name and Path cannot be both empty" -Presented $errorVar.Exception.Message
}

function TestingHelperTest_NewModuleV3_WithOutName_withPath {

    $folder = New-TestingFolder -Name "ModulefolderName" -PassThru
    $finalFolder = $folder.FullName | Join-Path -ChildPath "ModulefolderName"

    $result = New-TT_ModuleV3 -Path $folder @ErrorParameters

    Assert-AreEqualPath -Expected $finalFolder -Presented $result
    Assert-AddModuleV3 -Path $finalFolder
}

function TestingHelperTest_NewModuleV3_WithOutName_WithPath_AddAll {

    $folder = New-TestingFolder -Name "ModulefolderName" -PassThru
    $finalFolder = $folder.FullName | Join-Path -ChildPath "ModulefolderName"

    $result = New-TT_ModuleV3 -Path $folder -AddAll @ErrorParameters

    Assert-AreEqualPath -Expected $finalFolder -Presented $result
    Assert-AddAll -Path $folder

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

function TestingHelperTest_NewModuleV3_AddAll{

    $moduleName = "MyModule"
    $path = '.'
    $modulePath = $path | Join-Path -ChildPath $moduleName

    $result = New-TT_ModuleV3 -Name $moduleName -AddAll

    Assert-AreEqualPath -Expected $modulePath -Presented $result

    Assert-AddAll -Path $modulePath

}

