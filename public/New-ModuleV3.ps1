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
    [Alias("New-Module")]
    Param
    (
        # Name of the module
        [Parameter(Mandatory,ParameterSetName="Named")][string]$Name,
        # Description of the module
        [Parameter(ParameterSetName="Named")][string]$Description,
        # Author of the module
        [Parameter(ParameterSetName="Named")][string]$Author,
        # Version of the module
        [Parameter(ParameterSetName="Named")][string]$ModuleVersion,
        [Parameter(ParameterSetName="Named")]
        # Path where the module will be created. Default is current folder 
        [Parameter(ParameterSetName="WithPath")]
        [string]$Path,
        # Add all the sections of the module
        [Parameter()][switch]$AddAll,
        # Add Testing module
        [Parameter()][switch]$AddTesting,
        # Add Sample Code to the module and test
        [Parameter()][switch]$AddSampleCode,
        # Add devcontainer Json file
        [Parameter()][switch]$AddDevContainerJson,
        # Add Git repository
        [Parameter()][switch]$AddGitRepository,
        # Add a MIT Licenses file
        [Parameter()][switch]$AddLicense,
        # Add Readme file
        [Parameter()][switch]$AddReadme,
        # Add about topic
        [Parameter()][switch]$AddAbout,
        # Add deploy script
        [Parameter()][switch]$AdddeployScript,
        # Add release script
        [Parameter()][switch]$AddReleaseScript,
        # Add sync script
        [Parameter()][switch]$AddSyncScript,
        # Add PSScriptAnalyzer workflow
        [Parameter()][switch]$AddPSScriptAnalyzerWorkflow,
        # Add testing workflow
        [Parameter()][switch]$AddTestWorkflow,
        # Add deploy workflow
        [Parameter()][switch]$AddDeployWorkflow
    )

    $retModulePath = $null

    $modulePath = Get-ModulePath -Name $Name -RootPath $Path
    $moduleName = Get-ModuleName -Path $modulePath

    # check $modulePath and return if null
    if(!$modulePath -or !$moduleName){
        return $null
    }

    # If asked for testing add sample code on both modules
    $AddSampleCode = $AddSampleCode -or $AddTesting

    # Create the module
    if ($moduleName) {

        # Updatemanifest with the parameters
        $metadata = @{}
        if($Description){ $metadata.Description = $Description}
        if($Author){ $metadata.Author = $Author}
        if($ModuleVersion){ $metadata.ModuleVersion = $ModuleVersion}

        $retModulePath = Add-ModuleV3 -Name $moduleName -RootPath $modulePath -Metadata $metadata
        
        if(!$retModulePath){
            return $null
        }

        # Add Sample Code
        if($AddSampleCode){ $modulePath | Add-ToModuleSampleCode }
    }

    # Add All
    if($AddAll){ 
        $modulePath  | Add-ToModuleAll 

        return $retModulePath
    }

    # Add Testing
    if ($AddTesting){ $modulePath | Add-ToModuleTestAll  }

    # Add devcontainer.json file
    if($AddDevContainerJson){ $modulePath | Add-ToModuleDevContainerJson }

    # Add Git repository
    if($AddGitRepository){ $modulePath | Add-ToModuleGitRepository }

    # Add License file
    if($AddLicense){ $modulePath | Add-ToModuleLicense }

    # Add Readme file
    if($AddReadme){ $modulePath | Add-ToModuleReadme }

    # Add about 
    if($AddAbout){ $modulePath  | Add-ToModuleAbout }

    # Add deploying
    if($AddDeployScript){ $modulePath | Add-ToModuleDeployScript }

    # Add Release
    if($AddReleaseScript){ $modulePath | Add-ToModuleReleaseScript }

    # Add Sync
    if($AddSyncScript){ $modulePath | Add-ToModuleSyncScript }

    # Add PSScriptAnalyzer
    if($AddPSScriptAnalyzerWorkflow){ $modulePath | Add-ToModulePSScriptAnalyzerWorkflow }

    # Add Testing
    if($AddTestWorkflow){ $modulePath | Add-ToModuleTestWorkflow }

    # Add deploy Workflow
    if($AddDeployWorkflow){ $modulePath | Add-ToModuledeployWorkflow }

    return $retModulePath
    
} Export-ModuleMember -Function New-ModuleV3 -Alias New-Module