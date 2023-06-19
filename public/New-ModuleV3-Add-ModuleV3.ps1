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
        [Parameter()][hashtable]$Metadata
    ) 

    # Path
    $modulePath = Get-ModulePath -Name $Name -Path $Path

    # If $null Get-ModulePath failed
    if(!$modulePath){
        return $null
    }

    # PSM1
    $rootModule = "$Name.psm1"
    Import-Template -Path $modulePath -File $rootModule -Template "template.module.psm1"

    # public private
    $null = New-Item -ItemType Directory -Force -Path ($modulePath | Join-Path -ChildPath "public")
    $null = New-Item -ItemType Directory -Force -Path ($modulePath | Join-Path -ChildPath "private")

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