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
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][string]$RootPath,
        [Parameter()][hashtable]$Metadata,
        [Parameter()][switch]$AddSampleCode
    ) 

    # Resolve Path. Check if fails. 
    $modulePathString = Get-ModulePath -RootPath $Path -Name $Name
    if(!$modulePathString){return $null}

    # Create the module folder. Fail if exists
    # This will filter if Path already exist to avoid overwriting an existing module
    $modulePath = $modulePathString | New-Folder
    if( !$modulePath ){ return $null }

    $moduleName = Get-ModuleName -Path $modulePath

    # PSM1
    $rootModule = "$moduleName.psm1"
    Import-Template -Path $modulePath -File $rootModule -Template "template.module.psm1" -Force:$Force

    # public private
    $null = New-Item -ItemType Directory -Force -Path ($modulePath | Join-Path -ChildPath "public")
    $null = New-Item -ItemType Directory -Force -Path ($modulePath | Join-Path -ChildPath "private")

    # PSD1
    $psd1Path = ($modulePath | Join-Path -ChildPath "$moduleName.psd1") 

    try {
        # Create the PSD1 file
        New-MyModuleManifest  -Path $psd1Path -RootModule $rootModule -PreRelease "dev"

        # Update with metadata
        if ($Metadata.Count -gt 0) {
            Update-MyModuleManifest -Path $psd1Path -Metadata $metadata
        }
    }
    catch {
        Write-Error -Message ("Error creating the PSD1 file. " + $_.Exception.Message)
        return $null
    }

    return $modulePath | Convert-Path

} Export-ModuleMember -Function Add-ModuleV3