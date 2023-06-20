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
            [Parameter()][string]$Path,
            # Add Testing module
            [Parameter()][switch]$AddTesting
        )

        $retModulePath = $null

        $modulePath = Get-ModulePath -Name $Name -Path $Path -AppendName
        $moduleName = Get-ModuleName -Name $Name -ModulePath $modulePath

        # Create the module
        if ($moduleName) {

            # Updatemanifest with the parameters
            $metadata = @{}
            if($Description){ $metadata.Description = $Description}
            if($Author){ $metadata.Description = $Author}
            if($Version){ $metadata.Description = $Version}

            $retModulePath = Add-ModuleV3 -Name $moduleName -Path $modulePath -Metadata $metadata

            if(!$retModulePath){
                return $null
            }
        }

        if ($AddTesting) {
            if(!( Add-TestingToModuleV3 -Name $Name -Path $modulePath)){
                return $null
            }
        }

        return $retModulePath
    
} Export-ModuleMember -Function New-ModuleV3