
function TestingHelperTest_AddToModule_PipeCalls_NewModuleV3{

    $result = New-TT_ModuleV3 -Name "MyModule" | Add-TT_ToModuleLicense -PassThru 

    $result | Assert-Addlicense
}

function TestingHelperTest_AddToModule_PipeCalls_Folder{

    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleLicense -PassThru 
    $result | Assert-Addlicense
}

function TestingHelperTest_AddToModule_PipeCalls_Module{
    
    $moduleName = "AddToModule_PipeCalls_Module_" + (New-Guid).ToString().Substring(0,8) 

    $modulePath = New-TT_ModuleV3 -Name $moduleName
    Import-Module -Name $modulePath
    $module = Get-Module -Name $moduleName

    $result = $module | Add-TT_ToModuleLicense -PassThru 
    
    $result | Assert-Addlicense

    Remove-Module -Name $moduleName
}

function TestingHelperTest_AddToModule_PipeCalls_Chain{
    
    $modulePath = New-TT_ModuleV3 -Name "MyModule" 

    $result = $modulePath | Add-TT_ToModuleLicense -PassThru | Add-TT_ToModuleAbout
                
    $result | Assert-Addlicense 
    $result | Assert-AddToModuleAbout
}

function TestingHelperTest_AddToModule_FULL_PipeCalls_Folder{

    New-TestingFolder -Path "folderName"

    $result = Add-TT_ToModuleAll -PassThru -Path "./folderName" 
    $result | Assert-AddAll
}

function TestingHelperTest_AddToModule_FULL_PipeCalls_GetItem{

    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleAll -PassThru 
    $result | Assert-AddAll
}

function TestingHelperTest_AddToModule_FULL_PipeCalls_Module{
    
    $modulePath = New-TT_ModuleV3 -Name "MyModule" -Description "Module Description" -Author "myName" -ModuleVersion "5.5.5"

    Import-Module -Name $modulePath

    $module = Get-Module -Name "MyModule"
    $result = $module | Add-TT_ToModuleAll -PassThru
    $result | Assert-AddAll

    Remove-Module -Name "MyModule"
}



function TestingHelperTest_AddToModuleGitRepository_PipeCalls_Folder{
    
    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -PassThru 
    $result | Assert-AddGitRepository

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -PassThru @WarningParameters
    Assert-Contains -Expected "Git repository already exists." -Presented $warningVar

}

function TestingHelperTest_AddToModuleGitRepository_PipeCalls_Folder_Force{
    
    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -PassThru 
    $result | Assert-AddGitRepository

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -Force -PassThru @WarningParameters
    Assert-Contains -Expected "Reinitialized existing Git repository." -Presented $warningVar
}

