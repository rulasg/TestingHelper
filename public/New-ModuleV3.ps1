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
            # Add Publish script
            [Parameter()][switch]$AddPublishScript,
            # Add release script
            [Parameter()][switch]$AddReleaseScript,
            # Add sync script
            [Parameter()][switch]$AddSyncScript,
            # Add PSScriptAnalyzer workflow
            [Parameter()][switch]$AddPSScriptAnalyzerWorkflow,
            # Add testing workflow
            [Parameter()][switch]$AddTestingWorkflow,
            # Add publish workflow
            [Parameter()][switch]$AddPublishWorkflow
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
            if($Version){ $metadata.Version = $Version}

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
            $destination = $modulePath | Join-Path -ChildPath ".devcontainer"
            Import-Template -Path $destination -File "devcontainer.json" -Template "template.devcontainer.json"
        }

        # Add License file
        if($AddLicense){
            Import-Template -Path $modulePath -File "LICENSE" -Template "template.LICENSE.txt"
        }

        # Add Readme file
        if($AddReadme){
            $moduleManifest = Get-ModuleManifest -Path $modulePath
            Import-Template -Path $modulePath -File "README.md" -Template "template.README.md" -Replaces @{
                "_MODULE_NAME_" = $moduleName
                "_MODULE_DESCRIPTION_" = ($moduleManifest.Description ?? "A powershell module that will hold Powershell functionality.")
            }
        }

        # Add about 
        if($AddAbout){
            $moduleManifest = Get-ModuleManifest -Path $modulePath
            $destination = $modulePath | Join-Path -ChildPath "en-US"
            Import-Template -Path $destination -File "about_$moduleName.help.txt" -Template "template.about.help.txt" -Replaces @{
                "_MODULE_NAME_"        = ($moduleName ?? "<ModuleName>")
                "_MODULE_DESCRIPTION_" = ($moduleManifest.Description ?? "<Description>")
                "_AUTHOR_"             = ($moduleManifest.Author ?? "<Author>")
                "_COPYRIGHT_"          = ($moduleManifest.CopyRight ?? "<CopyRight>")
            }
        }

        # Add Publishing
        if($AddPublishScript){
            Import-Template -Path $modulePath -File "publish.ps1" -Template "template.v3.publish.ps1"
            Import-Template -Path $modulePath -File "publish-helper.ps1" -Template "template.v3.publish-helper.ps1"
        }

        # Add Release
        if($AddReleaseScript){
            Import-Template -Path $modulePath -File "release.ps1" -Template "template.v3.release.ps1"
        }

        # Add Sync
        if($AddSyncScript){
            Import-Template -Path $modulePath -File "sync.ps1" -Template "template.v3.sync.ps1"
            Import-Template -Path $modulePath -File "sync-helper.ps1" -Template "template.v3.sync-helper.ps1"
        }

        # Add PSScriptAnalyzer
        if($AddPSScriptAnalyzerWorkflow){
            $destination = $modulePath | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
            Import-Template -Path $destination -File "PSScriptAnalyzer.yml" -Template "template.v3.PSScriptAnalyzer.yml"
        }

        # Add Testing
        if($AddTestingWorkflow){
            $destination = $modulePath | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
            Import-Template -Path $destination -File "test_with_TestingHelper.yml" -Template "template.v3.test_with_TestingHelper.yml"
        }

        # Add Publish Workflow
        if($AddPublishWorkflow){
            $destination = $modulePath | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"
            Import-Template -Path $destination -File "publish_module_on_release.yml" -Template "template.v3.publish_module_on_release.yml"
        }

        return $retModulePath
    
} Export-ModuleMember -Function New-ModuleV3