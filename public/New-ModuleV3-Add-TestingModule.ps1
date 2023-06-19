function Add-TestingModuleV3 {
    [CmdletBinding()]
    Param
    (
        [Parameter()][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][hashtable]$Metadata
    ) 

    $testingModuleName = $Name + "Test"
    $testingModulePath = Get-ModulePath -Name $Name -Path $Path

    $result = Add-ModuleV3 -Name $testingModuleName -Path $testingModulePath -Metadata $Metadata

    if(!$result){
        Write-Error -Message ("Error creating the module [$testingModuleName].")
        return $null
    }

    return $result
    
} Export-ModuleMember -Function Add-TestingModuleV3