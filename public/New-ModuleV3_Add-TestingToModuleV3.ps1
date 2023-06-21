function Add-TestModuleV3 {
    [CmdletBinding()]
    Param
    (
        [Parameter()][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][hashtable]$Metadata
    ) 

    $testingModuleName = Get-TestModuleName -Name $Name
    $testingModulePath = Get-TestModulePath -Name $Name -Path $Path

    $result = Add-ModuleV3 -Name $testingModuleName -Path $testingModulePath -Metadata $Metadata

    if(!$result){
        Write-Error -Message ("Error creating the module [$testingModuleName].")
        return $null
    }

    return $result
    
} Export-ModuleMember -Function Add-TestModuleV3



function Add-TestingToModuleV3{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter()][hashtable]$Metadata,
        [Parameter()][switch]$AddSampleCode
    ) 

    $testModulePath = Add-TestModuleV3 -Path $Path -Name $Name -Metadata $Metadata

    if (!$testModulePath) {
        Write-Error -Message ("Error creating Testing for Module [$Name].")
        return $null
    }

    # Sample test
    if ($AddSampleCode) {
        $destination = $testModulePath | Join-Path -ChildPath "public"

        Import-Template -Path $destination -File "SampleFunctionTests.ps1" -Template "template.testmodule.functions.public.ps1" -Replaces @{
            '_MODULE_TESTING_' = $testingModuleName
            '_MODULE_TESTED_' = $ModuleName
        }
    }

    # Get root folder
    $modulePath = Get-ModulePath -Path $Path

    # test.ps1 script
    $testScriptPath = $modulePath | Join-Path -ChildPath "test.ps1"
    if($testScriptPath | Test-Path){
        Write-Warning "test.ps1 already exists."
    }
    else{
        Import-Template -Path $modulePath -File "test.ps1" -Template "template.test.ps1"
    }

    # launch.json
    $launchJsonPath = $modulePath | Join-Path -ChildPath '.vscode' -AdditionalChildPath 'launch.json'
    if($launchJsonPath | Test-Path){
        Write-Warning "launch.json already exists."
    }
    else{
        $destination = $modulePath | Join-Path -ChildPath '.vscode'
        Import-Template -Path $destination -File "launch.json" -Template "template.launch.json"
    }

    return $modulePath

} Export-ModuleMember -Function Add-TestingToModuleV3