<#
.Synopsis
   Created a Powershell module with V3 format.

.OUTPUTS
    Path of the module created
    $null if the module was not created
#>
function Add-ModuleV3 {
    [CmdletBinding()]
    Param
    (
        [Parameter()][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][hashtable]$Metadata,
        [Parameter()][switch]$AddSampleCode
    ) 

    # Resolve Path. Check if fails
    $modulePath = Get-ModulePath -Path $Path -Name $Name
    if(!$modulePath){return $null}

    # Create the module folder. Fail if exists
    if(!($modulePath | Add-Folder)){
        return $null
    }

    # PSM1
    $rootModule = "$Name.psm1"
    Import-Template -Path $modulePath -File $rootModule -Template "template.module.psm1"

    # public private
    $null = New-Item -ItemType Directory -Force -Path ($modulePath | Join-Path -ChildPath "public")
    $null = New-Item -ItemType Directory -Force -Path ($modulePath | Join-Path -ChildPath "private")

    # Sample code
    if ($AddSampleCode) {
        $destination = $modulePath | Join-Path -ChildPath "public"
        Import-Template -Path $destination -File "samplePublicFunction.ps1" -Template "template.module.functions.public.ps1"
        $destination = $modulePath | Join-Path -ChildPath "private"
        Import-Template -Path $destination -File "samplePrivateFunction.ps1" -Template "template.module.functions.private.ps1"
    }

    # PSD1
    $psd1Path = ($modulePath | Join-Path -ChildPath "$Name.psd1") 

    try {
        # Create the PSD1 file
        New-MyModuleManifest  -Path $psd1Path -RootModule $rootModule

        # Update with metadata
        if ($Metadata.Count -gt 0) {
            Update-MyModuleManifest -Path $psd1Path -Metadata $metadata
        }
    }
    catch {
        Write-Error -Message ("Error creating the PSD1 file. " + $_.Exception.Message)
        return $null
    }

    return $modulePath

} Export-ModuleMember -Function Add-ModuleV3