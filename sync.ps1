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

$MODULE_PATH    = $PSScriptRoot
$TOOLS_PATH     = $MODULE_PATH | Join-Path -ChildPath "tools"
$WORKFLOW_PATH  = $MODULE_PATH | Join-Path -ChildPath ".github" -AdditionalChildPath "workflows"

. ($TOOLS_PATH | Join-Path -ChildPath "sync.Helper.ps1")

Save-UrlContentToFile -File 'deploy_module_on_release.yml' -Folder $WORKFLOW_PATH  -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy_module_on_release.yml'
Save-UrlContentToFile -File 'powershell.yml'               -Folder $WORKFLOW_PATH  -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.powershell.yml'
Save-UrlContentToFile -File 'test_with_TestingHelper.yml'  -Folder $WORKFLOW_PATH  -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.test_with_TestingHelper.yml'

Save-UrlContentToFile -File 'deploy.helper.ps1'            -Folder $TOOLS_PATH     -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy.helper.ps1'
Save-UrlContentToFile -File 'deploy.ps1'                   -Folder $MODULE_PATH    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.deploy.ps1'

Save-UrlContentToFile -File 'sync.Helper.ps1'              -Folder $TOOLS_PATH     -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.sync.Helper.ps1'
Save-UrlContentToFile -File 'sync.ps1'                     -Folder $MODULE_PATH    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.sync.ps1'

Save-UrlContentToFile -File 'release.ps1'                  -Folder $MODULE_PATH    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.release.ps1'
Save-UrlContentToFile -File 'test.ps1'                     -Folder $MODULE_PATH    -Url 'https://raw.githubusercontent.com/rulasg/TestingHelper/main/private/templates/template.v3.test.ps1'