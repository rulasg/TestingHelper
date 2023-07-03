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

$MODULE_PATH = $PSScriptRoot

. ($MODULE_PATH | Join-Path -ChildPath "tools" -AdditionalChildPath "sync-helper.ps1")

Save-UrlContentToFile -FilePath 'deploy_module_on_release.yml' -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy_module_on_release.yml'  
Save-UrlContentToFile -FilePath 'powershell.yml'               -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.powershell.yml'                
Save-UrlContentToFile -FilePath 'test_with_TestingHelper.yml'  -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.test_with_TestingHelper.yml'   

Save-UrlContentToFile -FilePath 'deploy-helper.ps1'            -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy-helper.ps1'             
Save-UrlContentToFile -FilePath 'deploy.ps1'                   -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy.ps1'                    

Save-UrlContentToFile -FilePath 'sync-helper.ps1'              -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.sync-helper.ps1'               
Save-UrlContentToFile -FilePath 'sync.ps1'                     -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.sync.ps1'                      

Save-UrlContentToFile -FilePath 'release.ps1'                  -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.release.ps1'                   
Save-UrlContentToFile -FilePath 'test.ps1'                     -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.test.ps1'                      