<#
.SYNOPSIS
    Synchronizes TestingHelper templates wiles

.DESCRIPTION
    Synchronizes TestingHelper templates to the local repo.
    TestingHelper uses templates to create a new module. 
    This script will update the local module with the latest templates.
.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/sync.ps1
#>

[cmdletbinding(SupportsShouldProcess, ConfirmImpact='High')]
param()

function Get-UrlContent {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)][string]$url
    )
    $wc = New-Object -TypeName System.Net.WebClient
    $fileContent = $wc.DownloadString($url)

    return $fileContent
}

function Out-ContentToFile {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipeline)][string]$content,
        [Parameter(Mandatory=$true)][string]$filePath
    )

    if ($PSCmdlet.ShouldProcess($filePath, "Save content [{0}] to file" -f $content.Length)) {
        $content | Out-File -FilePath $filePath -Force
    }
}

Get-UrlContent -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/test.ps1'            | Out-ContentToFile -FilePath 'test.ps1'
Get-UrlContent -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/release.ps1'         | Out-ContentToFile -FilePath 'release.ps1'
Get-UrlContent -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/publish.ps1'         | Out-ContentToFile -FilePath 'publish.ps1'
Get-UrlContent -Url 'https://raw.githubusercontent.com/rulasg/DemoPsModule/main/publish-Helper.ps1'  | Out-ContentToFile -FilePath 'publish-Helper.ps1'
