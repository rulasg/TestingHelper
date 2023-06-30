<#
.SYNOPSIS
    Synchronizes with TestingHelper templates files

.DESCRIPTION
    Synchronizes with TestingHelper templates to the local repo.
    TestingHelper uses templates to create a new module. 
    This script will update the local module with the latest templates.
.LINK
    https://raw.githubusercontent.com/rulasg/TestingHelper/main/sync.ps1
#>

[cmdletbinding(SupportsShouldProcess)]
param()

. ($PSScriptRoot | Join-Path -ChildPath "sync-helper.ps1")

$modulePath = $PSScriptRoot 
$toolsPath = $PSScriptRoot | Join-Path -ChildPath "tools"
$workflowPath = $toolsPath | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"

Save-UrlContentToFile -File 'deploy_module_on_release.yml' -Folder $workflowPath    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy_module_on_release.yml'  
Save-UrlContentToFile -File 'powershell.yml'               -Folder $workflowPath    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.powershell.yml'                
Save-UrlContentToFile -File 'test_with_TestingHelper.yml'  -Folder $workflowPath    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.test_with_TestingHelper.yml'   

Save-UrlContentToFile -File 'deploy-helper.ps1'            -Folder $toolsPath       -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy-helper.ps1'             
Save-UrlContentToFile -File 'deploy.ps1'                   -Folder $modulePath      -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy.ps1'                    

Save-UrlContentToFile -File 'sync-helper.ps1'              -Folder $toolsPath       -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.sync-helper.ps1'               
Save-UrlContentToFile -File 'sync.ps1'                     -Folder $modulePath      -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.sync.ps1'                      

Save-UrlContentToFile -File 'release.ps1'                  -Folder $workflowPath    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.release.ps1'                   
Save-UrlContentToFile -File 'test.ps1'                     -Folder $modulePath      -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.test.ps1'                      