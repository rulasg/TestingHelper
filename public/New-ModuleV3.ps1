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

    $modulePath = Get-ModulePath -Name $Name -Path $Path -AppendName
    $moduleName = Get-ModuleName -Name $Name -ModulePath $modulePath

    # Create the module
    if ($moduleName) {

        # Updatemanifest with the parameters
        $metadata = @{}
        if($Description){ $metadata.Description = $Description}
        if($Author){ $metadata.Author = $Author}
        if($ModuleVersion){ $metadata.ModuleVersion = $Version}

        $retModulePath = Add-ModuleV3 -Name $moduleName -Path $modulePath -Metadata $metadata -AddSampleCode:$AddSampleCode

        if(!$retModulePath){
            return $null
        }
    }

    if ($AddTesting) {
        $result = Add-TestingToModuleV3 -Name $Name -Path $modulePath -AddSampleCode:$AddSampleCode
        
        # Check if the module was created
        if(! $result){
            return $null
        }
    }

    # Add devcontainer.json file
    if($AddDevContainerJson){
        $null = Add-ModuleDevContainerJson -Path $modulePath
    }

    # Add License file
    if($AddLicense){
        $null = Add-ModuleLicense -Path $modulePath
    }

    # Add Readme file
    if($AddReadme){
        $null = Add-ModuleReadme -Path $modulePath
    }

    # Add about 
    if($AddAbout){
        $null = Add-ModuleAbout -Path $modulePath 
    }

    # Add deploying
    if($AddDeployScript){
        $null = Add-ModuleDeployScript -Path $modulePath
    }

    # Add Release
    if($AddReleaseScript){
        $null = Add-ModuleReleaseScript -Path $modulePath
    }

    # Add Sync
    if($AddSyncScript){
        $null = Add-ModuleSyncScript -Path $modulePath
    }

    # Add PSScriptAnalyzer
    if($AddPSScriptAnalyzerWorkflow){
        $null = Add-ModulePSScriptAnalyzerWorkflow -Path $modulePath
    }

    # Add Testing
    if($AddTestingWorkflow){
        $null = Add-ModuleTestingWorkflow -Path $modulePath
    }

    # Add deploy Workflow
    if($AddDeployWorkflow){
        $null = Add-ModuledeployWorkflow -Path $modulePath
    }

    return $retModulePath
    
} Export-ModuleMember -Function New-ModuleV3 -Alias New-Module