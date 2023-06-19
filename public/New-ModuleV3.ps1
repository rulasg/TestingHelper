<#
.Synopsis
   Created a Powershell module with V3 format.

.DESCRIPTION
    Created a Powershell module adding the sections of the module requiested by the user.

.Example
    New-ModuleV3 -Name "MyModule" -Description "Module that will hold my functions"
    Create a module with the name MyModule and description "Module that will hold my functions"

.Example
    New-ModuleV3 -Name "MyModule" -Description "Module that will hold my functions" -FullModule
    Create the full version of the module with all the sections.

#>
function New-ModuleV3 {
    <#
    .Synopsis
       Created a Powershell module with V2 format.
    #>
        [CmdletBinding()]
        Param
        (
            # Name of the module
            [Parameter()][string]$Name,
            # Description of the module
            [Parameter()][string]$Description,
            # Author of the module
            [Parameter()][string]$Author,
            # Version of the module
            [Parameter()][string]$Version,
            # Path where the module will be created. Default is current folder 
            [Parameter()][string]$Path
        )

        # Create the module
        if ($Name) {

            # Updatemanifest with the parameters
            $metadata = @{}
            if($Description){ $metadata.Description = $Description}
            if($Author){ $metadata.Description = $Author}
            if($Version){ $metadata.Description = $Version}

            $modulePath = Add-ModuleV3 -Name $Name -Path $Path -Metadata $metadata

            if(!$modulePath){
                return $null
            }
        }

        return $modulePath
    
} Export-ModuleMember -Function New-ModuleV3



function Get-ModulePath{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][string]$Path
    )

    try {

        $path = [string]::IsNullOrWhiteSpace($Path) ? '.' : $Path

        $modulePath = $Path | Join-Path -ChildPath $Name
            
        if($modulePath | Test-Path){
            Write-Error "Path already exists."
            return $null
        } else {
           $null = New-Item -ItemType Directory -Name $modulePath

           if($modulePath | Test-Path){
                "Create folder [$modulePath]" | Write-Information
           } else {
               Write-Error "Path could not be created."
               return $null
           }
        }
        return $modulePath
    }
    catch {
        Write-Error -Message "Failed to find or create module path."
        return $null
    }
}