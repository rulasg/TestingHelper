function Get-DefaultsManifest {
    New-ModuleManifest -Path defaults.psd1 -RootModule defaults.psm1
    $defaultsManifest = Import-PowerShellDataFile -Path defaults.psd1 
    return $defaultsManifest
}

function Assert-AddModuleV3 {
    param(
        # Name of the folder to Assert
        [Parameter()][string]$Name,
        # ModulePath where to Assert the Module Content
        [Parameter()][string]$Path,
        # Metadata for the manifest to assert
        [Parameter()][hashtable]$Expected
    )
    
    $psdname = $Name + ".psd1"
    $psmName = $Name + ".psm1"

    $fullExpected = Get-DefaultsManifest
    
    # Update fullExpected with expected
    ForEach($key in $Expected.Keys) { $fullExpected[$key] = $Expected[$key]}

    #PSM1
    $psmPath = $Path | Join-Path -ChildPath $psmName
    Assert-ItemExist -Path $psmPath

    # public private
    Assert-ItemExist -Path ($Path | Join-Path -ChildPath "public") -Comment "public folder"
    Assert-ItemExist -Path ($Path | Join-Path -ChildPath "private") -Comment "private folder"

    #PSD1
    $psdPath = $Path | Join-Path -ChildPath  $psdname
    Assert-ItemExist -Path $psdPath

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

function Assert-TestingV3 {
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path,
        [Parameter()][hashtable]$Expected
    )

    # $modulePath = $Path | Join-Path -ChildPath $Name
    $testingModuleName = $moduleName + "Test"
    $testingModulePath = $path | Join-Path -ChildPath $testingModuleName

    Assert-AddModuleV3 -Name $testingModuleName -Path $testingModulePath -Expected $Expected
    Assert-LaunchJson -Path $modulePath
    Assert-TestScript -Path $modulePath -Name $moduleName
}

function Assert-LaunchJson{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path
    )

    $launchFile = $Path | Join-Path -ChildPath $Name -AdditionalChildPath ".vscode" , "launch.json"

    Assert-ItemExist -Path $launchFile -Comment "launch.json exists"
    $json = Get-Content -Path $launchFile | ConvertFrom-Json

    Assert-IsTrue -Condition ($json.configurations[0].name -eq 'PowerShell: Run Test')
    Assert-IsTrue -Condition ($json.configurations[0].type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations[0].Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations[0].Script -eq '${workspaceFolder}/test.ps1')
    Assert-IsTrue -Condition ($json.configurations[0].cwd -eq '${workspaceFolder}')

    Assert-IsTrue -Condition ($json.configurations[1].name -eq 'PowerShell Interactive Session')
    Assert-IsTrue -Condition ($json.configurations[1].type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations[1].Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations[1].cwd -eq '')
}

function Assert-TestScript{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path
    )

    $testps1Path = $Path | Join-Path -ChildPath "test.ps1"

    Assert-ItemExist -Path $testps1Path -Comment "test.ps1 exists"
}
