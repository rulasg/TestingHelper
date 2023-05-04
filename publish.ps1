<#
.SYNOPSIS
    Publish the Module to PSGallery
.DESCRIPTION
    This script will publish the module to the PSGallery
.NOTES
    You will need to create a NuGet API Key for the PSGallery at https://www.powershellgallery.com/account/apikeys
.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/publish.ps1
.EXAMPLE
    # Publish the module to the PSGallery without prompting

    > Publish.ps1 -Force -NuGetApiKey "<API Key>""
.EXAMPLE
    # Publish the module to the PSGallery using PAT on enviroment variable

    > $env:NUGETAPIKEY = <API Key>
    > ./publish.ps1
#>

[CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact='High'
    )]
param(
    # The NuGet API Key for the PSGallery
    [Parameter(Mandatory=$false)] [string]$NuGetApiKey,
    # Force the publish without prompting for confirmation
    [Parameter(Mandatory=$false)] [switch]$Force,
    # Force publishing package to the gallery. Equivalente to Import-Module -Force
    [Parameter(Mandatory=$false)] [switch]$ForcePublish
)

# check that $NuggetApiKey is null or whitespace
# If it is use environment variable $env:NugetApiKey
if ( [string]::IsNullOrWhiteSpace($NuGetApiKey) ) {
    
    if ( [string]::IsNullOrWhiteSpace($env:NUGETAPIKEY) ) {
        Write-Error -Message '$Env:NUGETAPIKEY is not set. Try running `$Env:NUGETAPIKEY = (Find-DocsFile nugetapikey | rsk | Get-SecretData).Get()`'
        return
    }
    
    $NuGetApiKey = $env:NUGETAPIKEY
}

# look for psd1 file on the same folder as this script
$psdPath = Get-ChildItem -Path $PSScriptRoot -Filter *.psd1

# check if $psd is set
if ( $null -eq $psdPath ) {
    Write-Error -Message 'No psd1 file found'
    return
}

# check if $psd is a single file
if ( $psdPath.Count -gt 1 ) {
    Write-Error -Message 'More than one psd1 file found'
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
    $message ="Publishing {0} {1} {2} to PSGallery ..." -f $($psdPath.Name), $($psd1.ModuleVersion), $($psd1.PrivateData.pSData.Prerelease)  
    # show an empty line
    Write-Information -InformationAction Continue -Message ""
    Write-Information -InformationAction Continue -Message $message 
    Publish-Module   -Name $psdPath -NuGetApiKey $NuGetApiKey -Force:$ForcePublish
}