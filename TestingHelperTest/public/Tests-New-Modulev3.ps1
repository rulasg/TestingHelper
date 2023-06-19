

function TestingHelperTest_NewModuleV3_WithName{

    Assert-NotImplemented
}


function TestingHelperTest_NewModuleV3_AddModule{

    $moduleName = "MyModule"

    $result = Add-TT_ModuleV3 -Name $moduleName -Path '.'

    $defaultsManifest = Get-DefaultsManifest

    $assertParam = @{
        Path = $result
        Name = $moduleName
        Description = $defaultsManifest.Description

        #ManifestDefaults
        Author = $defaultsManifest.Author
        CompanyName = $defaultsManifest.CompanyName
        ModuleVersion = $defaultsManifest.ModuleVersion
        Copyright = $defaultsManifest.CopyRight
        FunctionsToExport = $defaultsManifest.FunctionsToExport
    }
    Assert-AddModuleV3 -param $assertParam

}

function TestingHelperTest_NewModuleV3_CreateModule_WithOutName{
    
}

function TestingHelperTest_NewModuleV3_PathAlreadyExists{

    "MyModule" | New-TestingFolder 

    $result = Add-TT_ModuleV3 -Name "MyModule" -Path '.' @ErrorParameters

    Assert-IsNull -Object $result -Comment "No module is created"
    Assert-Count -Expected 1 -Presented $errorVar -Comment "One error is thrown"
    Assert-Contains -Expected "Path already exists." -Presented ($errorVar.Exception.Message)
}

function Get-DefaultsManifest{
    New-ModuleManifest -Path defaults.psd1 -RootModule defaults.psm1
    $defaultsManifest = Import-PowerShellDataFile -Path defaults.psd1 
    return $defaultsManifest
}
function Assert-AddModuleV3{
    param(
        [Parameter()][hashtable]$param
    )
    
    $psdname = $param.Name + ".psd1"
    $psmName = $param.Name + ".psm1"

    #PSD1
    $psdPath = $param.Path |Join-Path -ChildPath  $psdname
    Assert-ItemExist -Path $psdPath

    #PSM1
    $psmPath = $param.Path | Join-Path -ChildPath $psmName
    Assert-ItemExist -Path $psmPath

    #manifest
    $manifest = Import-PowerShellDataFile -Path $psdPath

    Assert-AreEqual -Expected $psmName -Presented $manifest.RootModule -Comment "RootModule"
    Assert-AreEqual -Expected $param.FunctionsToExport -Presented $manifest.FunctionsToExport -Comment "Manifest FunctionsToExport"
    Assert-AreEqual -Expected $param.CompanyName -Presented $manifest.CompanyName -Comment "Manifest CompanyName"
    Assert-AreEqual -Expected $param.ModuleVersion -Presented $manifest.ModuleVersion -Comment "Manifest ModuleVersion"
    Assert-AreEqual -Expected $param.Copyright -Presented $manifest.Copyright -Comment "Manifest Copyright"
    Assert-AreEqual -Expected $param.Author -Presented $manifest.Author -Comment "Manifest Author"

    Assert-AreEqual -Expected ($param.Description ?? "") -Presented ($manifest.Description ?? "") -Comment "Manifest Description"

    Write-AssertionSectionEnd
}
