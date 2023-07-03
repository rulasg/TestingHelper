# add help to script

<#
.SYNOPSIS
    Deploy a PowerShell module to the PowerShell Gallery.

.DESCRIPTION
    Functions library for deploying a PowerShell module to the PowerShell Gallery.

    This script is intended to be used as a helper for the Deploy.ps1 script.
    It is not intended to be used directly.

.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/deploy.Helper.ps1
    https://github.com/rulasg/TestingHelper/blob/main/private/templates/template.v3.deploy.Helper.ps1
    https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy.Helper.ps1

#>

Write-Information -MessageData ("Loading {0} ..." -f ($PSCommandPath | Split-Path -LeafBase))

# This functionalty should be moved to TestingHelper module to allow a simple Deploy.ps1 code.

function Invoke-DeployModuleToPSGallery{
    [CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact='High'
    )]
    param(
        # The NuGet API Key for the PSGallery
        [Parameter(Mandatory=$true)] [string]$NuGetApiKey,
        # Force the deploy without prompting for confirmation
        [Parameter(Mandatory=$false)] [switch]$Force,
        # Force deploying package to the gallery. Equivalente to Import-Module -Force
        [Parameter(Mandatory=$false)] [switch]$ForceDeploy,
        # Module Manifest Path
        [Parameter(Mandatory=$false)] [string]$ModuleManifestPath
    )

    $psdPath = $ModuleManifestPath

    # check if $psd is set
    if ( -not (Test-Path -Path $psdPath)) {
        Write-Error -Message 'No psd1 file found'
        return
    }

    # Display Module Information
    $psd1 = Import-PowerShellDataFile -Path $psdPath
    $psd1
    $psd1.PrivateData.PSData

    # Confirm if not forced
    if ($Force -and -not $Confirm){
        $ConfirmPreference = 'None'
    }
    
    # Deploy the module with ShouldProcess (-whatif, -confirm)
    if ($PSCmdlet.ShouldProcess($psdPath, "Invoke-DeployModule")) {
        "Deploying {0} {1} {2} to PSGallery ..." -f $($psd1.RootModule), $($psd1.ModuleVersion), $($psd1.PrivateData.pSData.Prerelease) | Write-Information
        # During testing we should use -WhatIf paarmetre when calling for deploy. 
        # Just reach this point when testing call failure
        Invoke-DeployModule -Name $psdPath -NuGetApiKey $NuGetApiKey -Force:$ForceDeploy
    }
}

function Update-DeployModuleManifest {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)][string]$VersionTag
    )

    $parameters = @{
        ModuleVersion = Get-DeployModuleVersion -VersionTag $VersionTag
        Path = $MODULE_PSD1
        Prerelease = Get-DeployModulePreRelease -VersionTag $VersionTag
    }

    # if ($PSCmdlet.ShouldProcess($parameters.Path, "Update-ModuleManifest with ModuleVersion:{0} Prerelease:{1}" -f $parameters.ModuleVersion, $parameters.Prerelease)) {
    if ($PSCmdlet.ShouldProcess($parameters.Path, "Update-ModuleManifest with $versionTag")) {
        "Updating module manifest with version tag [$VersionTag] ..." | Write-Information
        Update-ModuleManifest  @parameters   
        
    } else {
        Write-Warning -Message "Update-ModuleManifest skipped. Any PSD1 deploy will not have the proper version."
    }

    if($?){
        Write-Information -MessageData "Updated module manifest with version tag [$VersionTag]"
    }
    else{
        Write-Error -Message "Failed to update module manifest with version tag [$VersionTag]"
        exit 1
    }
} 

function script:Invoke-DeployModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$NuGetApiKey,
        [Parameter(Mandatory=$false)][switch]$Force
    )

    $parameters = @{
        Name = $Name
        NuGetApiKey = $NuGetApiKey
        Force = $Force
    }

    Publish-Module @parameters

    if($?){
        Write-Information -MessageData "Deployed module [$Name] to PSGallery"
    }
    else{
        Write-Error -Message "Failed to deploy module [$Name] to PSGallery"
        exit 1
    }
} 

function Get-DeployModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$VersionTag
    )

    $version = $VersionTag.split('-')[0] 
    #remove all leters from $version
    $version = $version -replace '[a-zA-Z_]'
    $version
}

function Get-DeployModulePreRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$VersionTag
    )

    $preRelease = $VersionTag.split('-')[1]
    # to clear the preRelease by Update-ModuleManifest 
    # preRelease must be a string with a space. 
    # $null or [string]::Empty leaves the value that has.
    $preRelease = $preRelease ?? " "
    $preRelease
}

