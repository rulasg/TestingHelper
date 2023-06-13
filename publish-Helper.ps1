# add help to script

<#
.SYNOPSIS
    Publish a PowerShell module to the PowerShell Gallery.

.DESCRIPTION
    Functions library for publishing a PowerShell module to the PowerShell Gallery.

    This script is intended to be used as a helper for the Publish.ps1 script.
    It is not intended to be used directly.

.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/publish-Helper.ps1

#>


Write-Information -MessageData ("Loading {0} ..." -f ($PSCommandPath | Split-Path -LeafBase))

# This functionalty should be moved to TestingHelper module to allow a simple Publish.ps1 code.

function Invoke-PublishModuleToPSGallery{
    [CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact='High'
    )]
    param(
        # The NuGet API Key for the PSGallery
        [Parameter(Mandatory=$true)] [string]$NuGetApiKey,
        # Force the publish without prompting for confirmation
        [Parameter(Mandatory=$false)] [switch]$Force,
        # Force publishing package to the gallery. Equivalente to Import-Module -Force
        [Parameter(Mandatory=$false)] [switch]$ForcePublish
    )

    # look for psd1 file on the same folder as this script
    $moduleName  = $PSScriptRoot | Split-Path -leaf
    $psdPath = $PSScriptRoot | Join-Path -ChildPath "$moduleName.psd1"

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
    
    # Publish the module with ShouldProcess (-whatif, -confirm)
    if ($PSCmdlet.ShouldProcess($psdPath, "Publish-Module")) {
        "Publishing {0} {1} {2} to PSGallery ..." -f $($psd1.RootModule), $($psd1.ModuleVersion), $($psd1.PrivateData.pSData.Prerelease) | Write-Information
        # During testing we should use -WhatIf paarmetre when calling for publish. 
        # Just reach this point when testing call failure
        Invoke-PublishModule -Name $psdPath -NuGetApiKey $NuGetApiKey -Force:$ForcePublish
    }
}

function Update-PublishModuleManifest {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)][string]$VersionTag
    )

    $parameters = @{
        ModuleVersion = Get-PublishModuleVersion -VersionTag $VersionTag
        Path = Get-PublishModuleManifestPath
        Prerelease = Get-PublishModulePreRelease -VersionTag $VersionTag
    }

    # if ($PSCmdlet.ShouldProcess($parameters.Path, "Update-ModuleManifest with ModuleVersion:{0} Prerelease:{1}" -f $parameters.ModuleVersion, $parameters.Prerelease)) {
    if ($PSCmdlet.ShouldProcess($parameters.Path, "Update-ModuleManifest with $versionTag")) {
        "Updating module manifest with version tag [$VersionTag] ..." | Write-Information
        Update-ModuleManifest  @parameters   
        
    } else {
        Write-Warning -Message "Update-ModuleManifest skipped. Any PSD1 publish will not have the proper version."
    }

    if($?){
        Write-Information -MessageData "Updated module manifest with version tag [$VersionTag]"
    }
    else{
        Write-Error -Message "Failed to update module manifest with version tag [$VersionTag]"
        exit 1
    }
} 

function Invoke-PublishModule {
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
        Write-Information -MessageData "Published module [$Name] to PSGallery"
    }
    else{
        Write-Error -Message "Failed to publish module [$Name] to PSGallery"
        exit 1
    }
} 

function Get-PublishModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$VersionTag
    )

    $version = $VersionTag.split('-')[0] 
    #remove all leters from $version
    $version = $version -replace '[a-zA-Z_]'
    $version
}

function Get-PublishModulePreRelease {
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

function Get-PublishModuleManifestPath {
    [CmdletBinding()]
    param()

    # look for psd1 file on the same folder as this script
    $moduleName  = $PSScriptRoot | Split-Path -leaf
    $psdPath = $PSScriptRoot | Join-Path -ChildPath "$moduleName.psd1"

    # check if $psd is set
    if ( -not (Test-Path -Path $psdPath)) {
        Write-Error -Message 'No psd1 file found'
        return
    } else {
        $psdPath
    }
}