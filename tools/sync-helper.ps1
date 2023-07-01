<#
.SYNOPSIS
    Helper functions to Synchronize TestingHelper templates files

.DESCRIPTION
    Helper functions Synchronize TestingHelper templates to the local repo.
    TestingHelper uses templates to create a new module. 
    This script will update the local module with the latest templates.
.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/sync.ps1
#>

[cmdletbinding()]
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

    process{

        if ($PSCmdlet.ShouldProcess($filePath, "Save content [{0}] to file" -f $content.Length)) {
            $content | Out-File -FilePath $filePath -Force
        }
    }
}

function Save-UrlContentToFile {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$FilePath
    )

    $fileContent = Get-UrlContent -Url $url

    if ([string]::IsNullOrWhiteSpace($fileContent)) {
        Write-Error -Message "Content from [$url] is empty"
        return
    } else {
        $fileContent | Out-ContentToFile -FilePath $filePath
        Write-Information -MessageData "Saved content to [$filePath] from [$url]"
    }
}