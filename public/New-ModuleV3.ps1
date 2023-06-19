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
            $Description
            $modulePath = Add-ModuleV3 @args
        }

        return $modulePath
    
} Export-ModuleMember -Function New-ModuleV3

<#
.Synopsis
   Created a Powershell module with V3 format.

.OUTPUTS
    Path of the module created
    $null if the module was not created
#>
function Add-ModuleV3 {
    <#
    .Synopsis
       Created a Powershell module with V2 format.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    ) 

    # Path
    $modulePath = Join-Path -Path $Path -ChildPath $Name

    if($modulePath | Test-Path){
        Write-Error "Path already exists."
        return $null
    }

    if(Test-Path($modulePath)){
        write-Error -Message "Folder already exists"
    } else {
       $null = New-Item -ItemType Directory -Name $modulePath
    }

    $psd1Path = ($modulePath | Join-Path -ChildPath "$Name.psd1") 
    $rootModule = "$Name.psm1"

    New-ModuleManifest -Path $psd1Path -RootModule $rootModule

    # PSM1
    Import-Template -Path $modulePath -File $rootModule -Template "template.module.psm1"

    return $modulePath

} Export-ModuleMember -Function Add-ModuleV3