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
        [Parameter()][hashtable]$Expected,
        # Switch to check SampleCode
        [Parameter()][switch]$AddSampleCode,
        #Switch to assert devcontainerjson file
        [Parameter()][switch]$AddDevContainerJson,
        # Switch to asser licens file
        [Parameter()][switch]$AddLicense,
        # Swithc to assert ReadME file
        [Parameter()][switch]$AddReadMe,
        # Switch to assert Deploy script
        [Parameter()][switch]$AddDeployScript,
        # Switch to assert release script
        [Parameter()][switch]$AddReleaseScript,
        # Switch to assert sync script
        [Parameter()][switch]$AddSyncScript,
        # Switch to assert PSScriptAnalyzer workflow
        [Parameter()][switch]$AddPSScriptAnalyzerWorkflow,
        # Switch to assert testing workflow
        [Parameter()][switch]$AddTestingWorkflow,
        # Switch to assert deploy workflow
        [Parameter()][switch]$AddDeployWorkflow

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

    # Sample code
    if ($AddSampleCode) {
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "public" | Join-Path -ChildPath "samplePublicFunction.ps1") -Comment "public function"
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "private" | Join-Path -ChildPath "samplePrivateFunction.ps1") -Comment "private function"
    }

    # Devcontainer.json
    if ($AddDevContainerJson) {
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath ".devcontainer" | Join-Path -ChildPath "devcontainer.json") -Comment "devcontainer.json"
    }

    # License
    if ($AddLicense) {
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "LICENSE") -Comment "LICENSE"
    }

    # ReadMe
    if ($AddReadMe) {
        $readMePath = $Path | Join-Path -ChildPath "README.md"
        Assert-ItemExist -Path $readMePath -Comment "README.md"
        Assert-IsTrue -Condition ((Get-Content -Path $readMePath) -contains "# $modulename")
    }

    # Deploy
    if ($AddDeployScript) {
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "deploy.ps1") -Comment "Deploy-Module.ps1"
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "deploy-helper.ps1") -Comment "Deploy-Module.ps1"
    }

    # release script
    if ($AddReleaseScript) {
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "release.ps1") -Comment "release.ps1"
    }

    # sync script
    if ($AddSyncScript) {
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "sync.ps1") -Comment "sync.ps1"
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "sync-helper.ps1") -Comment "sync-helper.ps1"
    }

    # PSScriptAnalyzer
    if ($AddPSScriptAnalyzerWorkflow) {
        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Assert-ItemExist -Path ($destination | Join-Path -ChildPath "powershell.yml") -Comment "powershell.yml"
    }

    # TestingWorkflow
    if ($AddTestingWorkflow) {
        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Assert-ItemExist -Path ($destination | Join-Path -ChildPath "test_with_TestingHelper.yml") -Comment "test_with_TestingHelper.yml"
    }

    # DeployWorkflow
    if ($AddDeployWorkflow) {
        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Assert-ItemExist -Path ($destination | Join-Path -ChildPath "deploy_module_on_release.yml") -Comment "deploy_module_on_release.yml"
    }

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
        [Parameter()][hashtable]$Expected,
        [Parameter()][switch]$AddSampleCode
    )

    # $modulePath = $Path | Join-Path -ChildPath $Name
    $testingModuleName = $Name + "Test"
    $testingModulePath = $path | Join-Path -ChildPath $testingModuleName

    Assert-AddModuleV3 -Name $testingModuleName -Path $testingModulePath -Expected $Expected
    Assert-LaunchJson -Path $modulePath
    Assert-TestScript -Path $modulePath

    if ($AddSampleCode) {
        $samplePublicPath = $testingModulePath | Join-Path -ChildPath "public" -AdditionalChildPath SampleFunctionTests.ps1
        Assert-ItemExist -Path $samplePublicPath
    }
}

function Assert-LaunchJson{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Path
    )

    $launchFile = $Path | Join-Path -ChildPath ".vscode" -AdditionalChildPath "launch.json"

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
        [Parameter()][string]$Path
    )

    $testps1Path = $Path | Join-Path -ChildPath "test.ps1"

    Assert-ItemExist -Path $testps1Path -Comment "test.ps1 exists"
}
