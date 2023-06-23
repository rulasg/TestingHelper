function Add-ModuleLicense{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        Import-Template -Path $Path -File "LICENSE" -Template "template.LICENSE.txt" -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleLicense

function Add-ModuleReleaseScript{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        Import-Template -Path $modulePath -File "release.ps1" -Template "template.v3.release.ps1" -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleReleaseScript

function Add-ModulePSScriptAnalyzerWorkflow{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        $destination = $Path | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
        Import-Template -Path $destination -File "powershell.yml" -Template "template.v3.powershell.yml"
    }
} Export-ModuleMember -Function Add-ModuleReleaseScript