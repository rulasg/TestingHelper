function Add-TestModuleV3 {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$AddSampleCode,
        [Parameter()][switch]$Force
    ) 

    $testingModuleName = Get-TestModuleName -Path $Path
    $testingModulePath = Get-TestModulePath -Path $Path
    
    # Generate metadata from the module if exists
    $manifestPath = Get-ModuleManifestPath -Path $Path
    if($manifestPath){
        $manifest = Import-PowerShellDataFile -Path $manifestPath

        # Probably we need to tune the metadata fo the testing module
        $manifest.Remove('Path')
        $manifest.Remove('PsdPath')
        $manifest.Remove('Name')
        $manifest.Remove('RootModule')
        $manifest.Remove('GUID')
    } 
    
    # TODO: Not sure how to mangage Force on Add-Module functions

    $result = Add-ModuleV3 -Name $testingModuleName -RootPath $testingModulePath -Metadata $manifest 
    
    if(!$result){
        Write-Error -Message ("Error creating the module [$testingModuleName].")
        return $null
    }
    
    # AddSampleCode
    if ($AddSampleCode) {
        $null = Add-ToModuleTestSampleCode -Path $Path -Force:$Force
    }

    return $result
    
} Export-ModuleMember -Function Add-TestModuleV3

