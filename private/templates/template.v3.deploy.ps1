<#
.SYNOPSIS
    Deploy module to PSGallery

.DESCRIPTION
    Deploy module to PSGallery

.PARAMETER VersionTag
    Update the module manifest with the version tag (Sample: v10.0.01-alpha)

.PARAMETER NuGetApiKey
    PAT for the PSGallery

.PARAMETER DependencyInjection
    DependencyInjection SCRIPTBLOCK to dot source mainly for testing

.EXAMPLE
    .\deploy.ps1 -VersionTag v10.0.01-alpha -NuGetApiKey $NUGETAPIKEY

.EXAMPLE
    $env:$NUGETAPIKEY = '****'
    .\deploy.ps1 -VersionTag v10.0.01-alpha 

.EXAMPLE
    .\deploy.ps1 -VersionTag v10.0.01-alpha -NuGetApiKey $NUGETAPIKEY -DependencyInjection $SCRIPTBLOCK_FOR_TESTING

.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/deploy.ps1

#>


[cmdletbinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    # Update the module manifest with the version tag (Sample: v10.0.01-alpha)
    [Parameter(Mandatory=$false)] [string]$VersionTag,
    # PAT for the PSGallery
    [Parameter(Mandatory=$false)] [string]$NuGetApiKey,
    # DependencyInjection Ps1 file
    [Parameter(Mandatory=$false)] [scriptblock]$DependencyInjection
)

$MODULE_PATH = $PSScriptRoot
$MODULE_NAME = $MODULE_PATH | Split-Path -LeafBase
$MODULE_PSD1 = Join-Path -Path $MODULE_PATH -ChildPath "$MODULE_NAME.psd1"
$MODULE_TOOLS = Join-Path -Path $MODULE_PATH -ChildPath "tools"

# Load helper 
# We dot souce the ps1 to allow all code to be in the same scope as the script
# Easier to inject for testing with DependecyInjection parameter
. ($MODULE_TOOLS | Join-Path -ChildPath "deploy.Helper.ps1")
if ($DependencyInjection) { 
    . $DependencyInjection 
}

# Process Tag
if($VersionTag){

    try {
        # Force manifest update even with -whatif
        Update-DeployModuleManifest  $VersionTag -whatif:$false
    }
    catch {
        Write-Error -Message "Failed to update module manifest with version tag [$VersionTag]. Error: $_"
        exit 1
    }
}

# check that $NuggetApiKey is null or whitespace
# If it is use environment variable $env:NugetApiKey
if ( [string]::IsNullOrWhiteSpace($NuGetApiKey) ) {
    if ( [string]::IsNullOrWhiteSpace($env:NUGETAPIKEY) ) {
        # Write-Error -Message '$Env:NUGETAPIKEY is not set. Try running `$Env:NUGETAPIKEY = (Find-DocsFile nugetapikey | rsk | Get-SecretData).Get()`'
        Write-Error -Message '$Env:NUGETAPIKEY is not set. Please set the variable with a PSGallery PAT or use -NuGetApiKey parameter.'
        exit 1
    }
    $NuGetApiKey = $env:NUGETAPIKEY
}

# Deploy module to PSGallery
Invoke-DeployModuleToPSGallery -NuGetApiKey $NuGetApiKey -Force -ModuleManifestPath $MODULE_PSD1
