
function TestingHelperTest_AddModuleSection_PipeCalls_NewModuleV3{

    $result = New-TT_ModuleV3 -Name "MyModule" | Add-TT_ToModuleLicense 

    $result | Assert-Addlicense
}

function TestingHelperTest_AddModuleSection_PipeCalls_Folder{

    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleLicense 
    $result | Assert-Addlicense
}

function TestingHelperTest_AddModuleSection_PipeCalls_Module{
    
    $moduleName = "AddModuleSection_PipeCalls_Module_" + (New-Guid).ToString().Substring(0,8) 

    $modulePath = New-TT_ModuleV3 -Name $moduleName
    Import-Module -Name $modulePath
    $module = Get-Module -Name $moduleName

    $result = $module | Add-TT_ToModuleLicense 
    
    $result | Assert-Addlicense

    Remove-Module -Name $moduleName
}

function TestingHelperTest_AddModuleSection_PipeCalls_Chain{
    
    $modulePath = New-TT_ModuleV3 -Name "MyModule" 

    $result1 = $modulePath | Add-TT_ToModuleLicense | Add-TT_ToModuleAbout 
                
    $result1 | Assert-Addlicense -PassThru | Assert-AddAbout
}

function TestingHelperTest_AddModuleSection_FULL_PipeCalls_Folder{

    New-TestingFolder -Path "folderName"

    $result = Add-TT_ToModuleAll -Path "./folderName"
    $result | Assert-AddFull
}

function TestingHelperTest_AddModuleSection_FULL_PipeCalls_GetItem{

    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleAll 
    $result | Assert-AddFull
}

function TestingHelperTest_AddModuleSection_FULL_PipeCalls_Module{
    
    $modulePath = New-TT_ModuleV3 -Name "MyModule" -Description "Module Description" -Author "myName" -ModuleVersion "5.5.5"

    Import-Module -Name $modulePath

    $module = Get-Module -Name "MyModule"
    $result = $module | Add-TT_ToModuleAll
    $result | Assert-AddFull

    Remove-Module -Name "MyModule"
}


