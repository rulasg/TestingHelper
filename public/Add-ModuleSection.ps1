# This is a set of functions that will add sections to a given module
# The intention is to allow the functions to be piped between them or even with the output of Get-Module
# The Ad-Module* functions will take 2 parametst
# -Path: The path of the module PS1 or PSM1 as Get-Module returns, But we will allow also the root of a module
# -Force: If the file already exists, it will be overwritten withe the default values
# The output will be the Path of the module updated. This way we may pipe with next Add-Module* function



function ReturnValue($Path,$Force){
    # create object with the two parameters as properties
    return [pscustomobject]@{
        Path = $Path
        Force = $Force
    }
}

function GetPath($Path){
    # Path should be a file or the folder where the module is located.
    # check if $Path is a file
    if(Test-Path -Path $Path -PathType Leaf){
        return $Path
    } else {
        # if not a file 
        return Get-ModuleManifest -Path $Path
    }
}


# Add devcontainer.json file
function Add-ModuleDevContainerJson{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        $destination = $Path | Join-Path -ChildPath ".devcontainer"
        Import-Template -Force:$Force -Path $destination -File "devcontainer.json" -Template "template.devcontainer.json"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleDevContainerJson

# Add License file
function Add-ModuleLicense{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        Import-Template -Force:$Force -Path $Path -File "LICENSE" -Template "template.LICENSE.txt"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleLicense

# Add Readme file
function Add-ModuleReadme{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        $moduleManifest = Get-ModuleManifest -Path $Path
        $moduleName = $Path | Split-Path -LeafBase
        Import-Template -Force:$Force -Path $Path -File "README.md" -Template "template.README.md" -Replaces @{
            "_MODULE_NAME_" = $moduleName
            "_MODULE_DESCRIPTION_" = ($moduleManifest.Description ?? "A powershell module that will hold Powershell functionality.")
        }
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleReadme

# Add about 
function Add-ModuleAbout{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        $moduleManifest = Get-ModuleManifest -Path $Path
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
} Export-ModuleMember -Function Add-ModuleAbout

# Add deploying
function Add-ModuleDeployScript{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        Import-Template -Force:$Force -Path $Path -File "deploy.ps1" -Template "template.v3.deploy.ps1"
        Import-Template -Force:$Force -Path $Path -File "deploy-helper.ps1" -Template "template.v3.deploy-helper.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleDeployScript

# Add Release
function Add-ModuleReleaseScript{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        Import-Template -Force:$Force -Path $Path -File "release.ps1" -Template "template.v3.release.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleReleaseScript

# Add Sync
function Add-ModuleSyncScript{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        Import-Template -Force:$Force -Path $Path -File "sync.ps1" -Template "template.v3.sync.ps1"
        Import-Template -Force:$Force -Path $Path -File "sync-helper.ps1" -Template "template.v3.sync-helper.ps1"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleSyncScript

# Add PSScriptAnalyzer
function Add-ModulePSScriptAnalyzerWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Force:$Force -Path $destination -File "powershell.yml" -Template "template.v3.powershell.yml"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModulePSScriptAnalyzerWorkflow

# Add Testing
function Add-ModuleTestingWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Force:$Force -Path $destination -File "test_with_TestingHelper.yml" -Template "template.v3.test_with_TestingHelper.yml"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleTestingWorkflow

# Add deploy Workflow
function Add-ModuledeployWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        if(!(GetPath -Path:$Path)){return $null}

        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Force:$Force -Path $destination -File "deploy_module_on_release.yml" -Template "template.v3.deploy_module_on_release.yml"
    
        return ReturnValue -Path $Path -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuledeployWorkflow