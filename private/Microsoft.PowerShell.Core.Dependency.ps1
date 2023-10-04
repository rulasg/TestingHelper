# Dependecy with Microsoft.PowerShell.Core functions

function script:New-MyModuleManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$RootModule,
        [Parameter(Mandatory)][string]$PreRelease
    )
    New-ModuleManifest  -Path $Path -RootModule $RootModule -PreRelease $PreRelease
}

function script:Update-MyModuleManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][hashtable]$Metadata
    )
    Update-ModuleManifest  -Path $Path @Metadata
}