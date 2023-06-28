function GetRooTestingFolderPath{
    # get the first 6 char of a guid
    $random = (New-Guid).ToString().Substring(0,6)
    $rd = Get-Date -Format yyMMdd
    $path = Join-Path -Path "Temp:" -ChildPath ("Posh_Testing_{0}_{1}" -f $rd,$random)
    return $path
}

function Push-TestingFolder {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string] $Path
    )

    $originalPath = Resolve-Path .

    if ($Path) {
        $testFolderName = $Path
    }
    else {
        $testFolderName = Join-Path -Path (GetRooTestingFolderPath) -ChildPath  $TestRunFolderName
    }
    New-TestingFolder $testFolderName
    $TestRunPath = Resolve-Path -Path $testFolderName

    if (Test-Path -Path $TestRunPath) { Remove-Testingfolder -Path $TestRunPath }

    New-Item -Path $TestRunPath  -ItemType "directory" -Force | Out-Null

    Set-Location -Path $TestRunPath

    return $originalPath
}

function Pop-TestingFolder {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string] $Path,
        [switch] $Force
    )

    $local = Get-Location | Resolve-Path
    $localLeaf = $local | Split-Path -Leaf

    Set-Location -Path $Path

    if (($localLeaf -eq $TestRunFolderName) -or $Force) {
        Remove-TestingFolder -Path $local
    }
}