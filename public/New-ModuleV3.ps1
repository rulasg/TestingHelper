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
        [Parameter()][string]$Name,
        # Description of the module
        [Parameter()][string]$Description,
        # Author of the module
        [Parameter()][string]$Author,
        # Version of the module
        [Parameter()][string]$ModuleVersion,
        # Path where the module will be created. Default is current folder 
        [Parameter()][string]$Path,
        # Add Testing module
        [Parameter()][switch]$AddTesting,
        # Add Sample Code to the module and test
        [Parameter()][switch]$AddSampleCode,
        # Add devcontainer Json file
        [Parameter()][switch]$AddDevContainerJson,
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
        [Parameter()][switch]$AddTestingWorkflow,
        # Add deploy workflow
        [Parameter()][switch]$AddDeployWorkflow
    )

    $retModulePath = $null

    $modulePath = Get-ModulePath -Name $Name -RootPath $Path
    $moduleName = Get-ModuleName -Path $modulePath

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
        if($AddSampleCode){
            $null = Add-ToModuleSampleCode -Path $modulePath
        }
    }

    if ($AddTesting) {
        $result = Add-TestToModuleAll -Path $modulePath
        
        # Check if the module was created
        if(! $result){
            return $null
        }

        # Add Sample Code
        if($AddSampleCode){
            $null = Add-TestSampleCode -Path $modulePath
        }
    }

    # Add devcontainer.json file
    if($AddDevContainerJson){
        $null = Add-ToModuleDevContainerJson -Path $modulePath
    }

    # Add License file
    if($AddLicense){
        $null = Add-ToModuleLicense -Path $modulePath
    }

    # Add Readme file
    if($AddReadme){
        $null = Add-ToModuleReadme -Path $modulePath
    }

    # Add about 
    if($AddAbout){
        $null = Add-ToModuleAbout -Path $modulePath 
    }

    # Add deploying
    if($AddDeployScript){
        $null = Add-ToModuleDeployScript -Path $modulePath
    }

    # Add Release
    if($AddReleaseScript){
        $null = Add-ToModuleReleaseScript -Path $modulePath
    }

    # Add Sync
    if($AddSyncScript){
        $null = Add-ToModuleSyncScript -Path $modulePath
    }

    # Add PSScriptAnalyzer
    if($AddPSScriptAnalyzerWorkflow){
        $null = Add-ToModulePSScriptAnalyzerWorkflow -Path $modulePath
    }

    # Add Testing
    if($AddTestingWorkflow){
        $null = Add-ToModuleTestingWorkflow -Path $modulePath
    }

    # Add deploy Workflow
    if($AddDeployWorkflow){
        $null = Add-ToModuledeployWorkflow -Path $modulePath
    }

    return $retModulePath
    
} Export-ModuleMember -Function New-ModuleV3 -Alias New-Module