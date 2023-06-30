
function TestingHelperTest_AssertAddSection_throwOnNull{
# All asserts here has a pattern
# This test will confirm tht the pattern will not miss a false negative
    
    $hasthrown = $false
    try{
        Assert-AddLicense -Path $null
    }
    catch{
        $hasthrown = $true
    }
    Assert-IsTrue -Condition $hasthrown
}

# Devcontainer.json
function Assert-AddDevContainerJson{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        Assert-ItemExist -Path ($Path | Join-Path -ChildPath ".devcontainer" | Join-Path -ChildPath "devcontainer.json") -Comment "devcontainer.json"
    }
}


# License
function Assert-AddLicense{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "LICENSE") -Comment "LICENSE"
    }
}

# ReadMe
function Assert-AddReadMe{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $name = $Path | Split-Path -LeafBase
        $readMePath = $Path | Join-Path -ChildPath "README.md"
        Assert-ItemExist -Path $readMePath -Comment "README.md"
        $content = Get-Content -Path $readMePath

        Assert-Contains -Expected "# $name" -Presented $content -Comment "README.md contains module name"

        $manifest = Import-ModuleManifest -Path $Path
        if($manifest){
            $expectedDescription = $manifest.Description ?? "A powershell module that will hold Powershell functionality."
            Assert-Contains -Expected $expectedDescription -Presented $content -Comment "README.md contains module description"
        }
    }
}

# AddAbout
function Assert-AddToModuleAbout{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $name = $Path | Split-Path -LeafBase
        $aboutFilePath = $Path | Join-Path -ChildPath "en-US" -AdditionalChildPath "about_$name.help.txt"
        Assert-ItemExist -Path $aboutFilePath -Comment "Missing about file"
    
        $aboutContent = Get-Content -Path $aboutFilePath | Out-String
        Assert-IsTrue -Condition ($aboutContent.Contains("TOPIC`n    about_$moduleName")) -Comment "TOPIC"
        Assert-IsTrue -Condition ($aboutContent.Contains("KEYWORDS`n    Powershell Testing UnitTest Module TestingHelper")) -Comment "KEYWORDS"

        # we will let to fail if manifest not present on assert
        $moduleMonifest = Import-ModuleManifest -Path $Path
        if($moduleMonifest){
            Assert-IsTrue -Condition ($aboutContent.Contains("AUTHOR`n    {0}"            -f $moduleMonifest.Author)) -Comment "Author"
            Assert-IsTrue -Condition ($aboutContent.Contains("SHORT DESCRIPTION`n    {0}" -f $moduleMonifest.Description)) -Comment "Description"
            Assert-IsTrue -Condition ($aboutContent.Contains("COPYRIGHT`n    {0}"         -f $moduleMonifest.CopyRight)) -Comment "CopyRight"
        }
    }
}

# Deploy
function Assert-AddDeployScript{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $toolsPath = $Path | Join-Path -ChildPath "tools"

        Assert-ItemExist -Path ($Path      | Join-Path -ChildPath "deploy.ps1") -Comment "deploy.ps1"
        Assert-ItemExist -Path ($toolsPath | Join-Path -ChildPath "deploy-helper.ps1") -Comment "deploy-helper.ps1"
    }
}

# release script
function Assert-AddReleaseScript{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "release.ps1") -Comment "release.ps1"
    }
}

# sync script
function Assert-AddSyncScript{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "sync.ps1") -Comment "sync.ps1"
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "sync-helper.ps1") -Comment "sync-helper.ps1"
    }
}


# PSScriptAnalyzer
function Assert-AddPSScriptAnalyzerWorkflow{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Assert-ItemExist -Path ($destination | Join-Path -ChildPath "powershell.yml") -Comment "powershell.yml"
    }
}


# TestingWorkflow
function Assert-AddTestWorkflow{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Assert-ItemExist -Path ($destination | Join-Path -ChildPath "test_with_TestingHelper.yml") -Comment "test_with_TestingHelper.yml"
    }
}


# DeployWorkflow
function Assert-AddDeployWorkflow{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Assert-ItemExist -Path ($destination | Join-Path -ChildPath "deploy_module_on_release.yml") -Comment "deploy_module_on_release.yml"
    }
}

# SampleCodes
function Assert-AddSampleCodes{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "public" | Join-Path -ChildPath "samplePublicFunction.ps1") -Comment "public function"
        Assert-ItemExist -Path ($Path | Join-Path -ChildPath "private" | Join-Path -ChildPath "samplePrivateFunction.ps1") -Comment "private function"
    }
}

#Testing SampleCode
function Assert-AddTestSampleCodes{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        $name = $Path | Split-Path -LeafBase
        $testingModuleName = $Name + "Test"
        $testingModulePath = $path | Join-Path -ChildPath $testingModuleName

        $samplePublicPath = $testingModulePath | Join-Path -ChildPath "public" -AdditionalChildPath SampleFunctionTests.ps1
        Assert-ItemExist -Path $samplePublicPath
    }
}

# Testing launch.json
function Assert-AddTestLaunchJson{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

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
}

# Testing TestScript
function Assert-AddTestTestScript{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path


        $testps1Path = $Path | Join-Path -ChildPath "test.ps1"

        Assert-ItemExist -Path $testps1Path -Comment "test.ps1 exists"
    }
}

# Asser Full module V3
function Assert-AddModuleV3{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        # Manifest data to check
        [Parameter()][hashtable]$Expected
    )
    process{
        $Path = $Path | Convert-Path

        $name = $Path | Split-Path -LeafBase

        $psdname = $name + ".psd1"
        $psmName = $name + ".psm1"
    
        $fullExpected = Get-DefaultsManifest
        
        # Update fullExpected with expected
        ForEach($key in $Expected.Keys) { $fullExpected[$key] = $Expected[$key]}
        $fullExpected.RootModule = $psmName
    
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
        # @("RootModule", "AliasesToExport" , "Author" , "CmdletsToExport" , "VariablesToExport" , "ModuleVersion" , "Copyright" , "CompanyName") | ForEach-Object {
        # $fullExpected | ForEach-Object {
        foreach($key in $Expected.Keys){

            # Check if value is NULL
            if (!($fullExpected.$Key)) {
                Assert-IsNull -Object $presented.$key -Comment "Manifest $key"
            }

            # skip if $Key is GUID
            if ($key -eq "GUID") { continue }

            # Check value based on type
            switch ($fullExpected.$key.GetType().Name) {
                "String" { 
                    Assert-AreEqual -Expected $fullExpected.$key   -Presented $presented.$key   -Comment "Manifest $key" 
                }
                "Object[]" { 
                    Assert-AreEqual -Expected ($fullExpected.$key | ConvertTo-Json) -Presented ($presented.$key | ConvertTo-Json) -Comment "Manifest $key"
                }
                "Hashtable" {
                    Assert-AreEqual -Expected ($fullExpected.$key | ConvertTo-Json) -Presented ($presented.$key | ConvertTo-Json) -Comment "Manifest $key"
                }
                Default {
                    throw "Unknown type for $key"
                }
            }
        }
    
        Write-AssertionSectionEnd
    }
}

function Assert-AddTestModuleV3{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )

    process{
        $Path = $Path | Convert-Path

        $name = $Path | Split-Path -LeafBase

        # $modulePath = $Path | Join-Path -ChildPath $Name
        $testingModuleName = $name + "Test"
        $testingModulePath = $path | Join-Path -ChildPath $testingModuleName
        
        Assert-AddModuleV3 -Path $testingModulePath
    }
}

function Assert-AddTestAll {
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )

    process{
        $Path = $Path | Convert-Path

        $name = $Path | Split-Path -LeafBase

        # $modulePath = $Path | Join-Path -ChildPath $Name
        $testingModuleName = $name + "Test"
        $testingModulePath = $path | Join-Path -ChildPath $testingModuleName
        
        Assert-AddModuleV3 -Path $testingModulePath
        Assert-AddTestSampleCodes -Path $Path

        Assert-AddTestTestScript -Path $Path
        Assert-AddTestLaunchJson -Path $Path
    }
}

# Full
function Assert-AddAll{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path
        
        $Path | Assert-AddDevContainerJson
        $Path | Assert-AddGitRepository
        $Path | Assert-AddLicense
        $Path | Assert-AddReadMe
        $Path | Assert-AddToModuleAbout
        $Path | Assert-AddDeployScript
        $Path | Assert-AddReleaseScript
        $Path | Assert-AddSyncScript
        $Path | Assert-AddPSScriptAnalyzerWorkflow
        $Path | Assert-AddTestWorkflow
        $Path | Assert-AddDeployWorkflow
        $Path | Assert-AddSampleCodes

        $Path | Assert-AddTestAll
        $Path | Assert-AddTestSampleCodes
    }
}




