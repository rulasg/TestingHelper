# This is a set of functions that will add sections to a given module
# The intention is to allow the functions to be piped between them or even with the output of Get-Module
# The Ad-Module* functions will take 2 parametst
# -Path: The path of the module PS1 or PSM1 as Get-Module returns, But we will allow also the root of a module
# -Force: If the file already exists, it will be overwritten withe the default values
# The output will be the Path of the module updated. This way we may pipe with next Add-ToModule* function



function ReturnValue($Path,$Force){
    # create object with the two parameters as properties
    return [pscustomobject]@{
        Path = $Path
        Force = $Force
    }
}

# Normalize $Path and returns $null if not valid
function GetPath($Path){
    # Path returned should be the folder where the module is located.
    # We may input the RootModule as if we pipe Get-Module command.
    # check if $Path is a file and get the parent of it

    if(Test-Path -Path $Path -PathType Leaf){
        $ret = $Path | Split-Path -Parent
    } else {
        $ret = $Path
    }

    return  $ret | Convert-Path
}

function Add-ToModuleSampleCode{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $destination = $modulePath | Join-Path -ChildPath "public"
        Import-Template -Path $destination -File "samplePublicFunction.ps1" -Template "template.module.functions.public.ps1"
        
        $destination = $modulePath | Join-Path -ChildPath "private"
        Import-Template -Path $destination -File "samplePrivateFunction.ps1" -Template "template.module.functions.private.ps1"
        
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleSampleCode

function Add-TestSampleCode{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $moduleName = Get-ModuleName -Path $Path
        $testModulePath = Get-TestModulePath -Path $Path 
        $testModulename = Get-TestModuleName -Path $Path
        $destination = $testModulePath | Join-Path -ChildPath "public"

        Import-Template -Path $destination -File "SampleFunctionTests.ps1" -Template "template.testmodule.functions.public.ps1" -Replaces @{
            '_MODULE_TESTING_' = $testModulename
            '_MODULE_TESTED_' = $ModuleName
        }
        
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleSampleCode


# Add devcontainer.json file
function Add-ToModuleDevContainerJson{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $destination = $Path | Join-Path -ChildPath ".devcontainer"
        Import-Template -Force:$Force -Path $destination -File "devcontainer.json" -Template "template.devcontainer.json"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleDevContainerJson

# Add License file
function Add-ToModuleLicense{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        Import-Template -Force:$Force -Path $Path -File "LICENSE" -Template "template.LICENSE.txt"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleLicense

# Add Readme file
function Add-ToModuleReadme{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        try{$moduleManifest = Get-ModuleManifest -Path $Path }catch{$moduleManifest = $null}
        $moduleName = $Path | Split-Path -LeafBase
        Import-Template -Force:$Force -Path $Path -File "README.md" -Template "template.README.md" -Replaces @{
            "_MODULE_NAME_" = $moduleName
            "_MODULE_DESCRIPTION_" = ($moduleManifest.Description ?? "A powershell module that will hold Powershell functionality.")
        }
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleReadme

# Add about 
function Add-ToModuleAbout{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        try{$moduleManifest = Get-ModuleManifest -Path $Path} catch{$moduleManifest = $null}
        $moduleName = $Path | Split-Path -LeafBase
        $destination = $Path | Join-Path -ChildPath "en-US"
        Import-Template -Force:$Force -Path $destination -File "about_$moduleName.help.txt" -Template "template.about.help.txt" -Replaces @{
            "_MODULE_NAME_"        = ($moduleName ?? "<ModuleName>")
            "_MODULE_DESCRIPTION_" = ($moduleManifest.Description ?? "<Description>")
            "_AUTHOR_"             = ($moduleManifest.Author ?? "<Author>")
            "_COPYRIGHT_"          = ($moduleManifest.CopyRight ?? "<CopyRight>")

        }
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleAbout

# Add deploying
function Add-ToModuleDeployScript{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        Import-Template -Force:$Force -Path $Path -File "deploy.ps1" -Template "template.v3.deploy.ps1"
        Import-Template -Force:$Force -Path $Path -File "deploy-helper.ps1" -Template "template.v3.deploy-helper.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleDeployScript

# Add Release
function Add-ToModuleReleaseScript{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        Import-Template -Force:$Force -Path $Path -File "release.ps1" -Template "template.v3.release.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleReleaseScript

# Add Sync
function Add-ToModuleSyncScript{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        Import-Template -Force:$Force -Path $Path -File "sync.ps1" -Template "template.v3.sync.ps1"
        Import-Template -Force:$Force -Path $Path -File "sync-helper.ps1" -Template "template.v3.sync-helper.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleSyncScript

# Add PSScriptAnalyzer
function Add-ToModulePSScriptAnalyzerWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Force:$Force -Path $destination -File "powershell.yml" -Template "template.v3.powershell.yml"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModulePSScriptAnalyzerWorkflow

# Add Testing
function Add-ToModuleTestingWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Force:$Force -Path $destination -File "test_with_TestingHelper.yml" -Template "template.v3.test_with_TestingHelper.yml"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleTestingWorkflow

# Add deploy Workflow
function Add-ToModuleDeployWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Force:$Force -Path $destination -File "deploy_module_on_release.yml" -Template "template.v3.deploy_module_on_release.yml"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleDeployWorkflow

function Add-ToModuleAll{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        $null = $Path | Add-ToModuleDevContainerJson         -Force:$Force
        $null = $Path | Add-ToModuleLicense                  -Force:$Force
        $null = $Path | Add-ToModuleReadme                   -Force:$Force
        $null = $Path | Add-ToModuleAbout                    -Force:$Force
        $null = $Path | Add-ToModuleDeployScript             -Force:$Force
        $null = $Path | Add-ToModuleReleaseScript            -Force:$Force
        $null = $Path | Add-ToModuleSyncScript               -Force:$Force
        $null = $Path | Add-ToModulePSScriptAnalyzerWorkflow -Force:$Force
        $null = $Path | Add-ToModuleTestingWorkflow          -Force:$Force
        $null = $Path | Add-ToModuleDeployWorkflow           -Force:$Force 
        
        return ReturnValue -Path $Path -Force:$Force

    }

} Export-ModuleMember -Function Add-ToModuleAll

# Add test.ps1 script
function Add-ToModuleTestScript{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null

        Import-Template -Force:$Force -Path $Path -File "test.ps1" -Template "template.v3.test.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleTestScript

# Add launch.json to module
function Add-ToModuleLaunchJson{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter()][switch]$Force
    )

    process{
        $Path = GetPath -Path:$Path ?? return $null
        $destination = $Path | Join-Path -ChildPath ".vscode"

        Import-Template -Force:$Force -Path $destination -File "launch.json" -Template "template.launch.json"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ToModuleLaunchJson
