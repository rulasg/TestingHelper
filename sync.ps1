<#
.SYNOPSIS
    Synchronizes TestingHelper templates files

.DESCRIPTION
    Synchronizes TestingHelper templates to the local repo.
    TestingHelper uses templates to create a new module. 
    This script will update the local module with the latest templates.
.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/sync.ps1
#>

[cmdletbinding()]
param()

. ($PSScriptRoot | Join-Path -ChildPath "sync-Helper.ps1")

Save-UrlContentToFile -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/test.ps1'            -FilePath 'test.ps1'
Save-UrlContentToFile -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/release.ps1'         -FilePath 'release.ps1'
Save-UrlContentToFile -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/publish.ps1'         -FilePath 'publish.ps1'
Save-UrlContentToFile -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/publish-Helper.ps1'  -FilePath 'publish-Helper.ps1'
