function Add-TestModuleV3 {
    [CmdletBinding()]
    Param
    (
        [Parameter()][string]$Path,
        [Parameter()][switch]$AddSampleCode
    ) 

    $testingModuleName = Get-TestModuleName -Path $Path
    $testingModulePath = Get-TestModulePath -Path $Path

    # Generate metadata from the module
    $manifest = Get-ModuleManifest -Path $Path
    # Probably we need to tune the metadata fo the testing module
    $manifest.Remove('Path')
    $manifest.Remove('PsdPath')
    $manifest.Remove('Name')
    $manifest.Remove('RootModule')
    $manifest.Remove('GUID')


    $result = Add-ModuleV3 -Name $testingModuleName -RootPath $testingModulePath -Metadata $manifest

    if(!$result){
        Write-Error -Message ("Error creating the module [$testingModuleName].")
        return $null
    }

    # AddSampleCode
    if ($AddSampleCode) {
        $null = Add-TestSampleCode -Path $result
    }

    return $result
    
} Export-ModuleMember -Function Add-TestModuleV3



function Add-TestToModuleAll{
    [CmdletBinding()]
    Param
    (
        [Parameter()][string]$Path
    ) 

    $Path = [string]::IsNullOrWhiteSpace($Path) ? '.' : $Path

    #if Path is null return
    $modulePath = Get-ModulePath -RootPath $Path
    if(!$modulePath){return $null}
    
    # Test Module
    $testModulePath = Add-TestModuleV3 -Path $Path -AddSampleCode
    
    if (!$testModulePath) {
        $name = Get-ModuleName -Path $Path
        Write-Error -Message ("Error creating Testing for Module [$Name].")
        return $null
    }

    # Add test.ps1
    $null = Add-ToModuleTestScript -Path $modulePath

    # Add launch.json
    $null = Add-ToModuleLaunchJson -Path $modulePath

    return $modulePath | Convert-Path

} Export-ModuleMember -Function Add-TestToModuleAll