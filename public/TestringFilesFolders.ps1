function Remove-TestingFolder {
    param(
        [Parameter(Mandatory, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string] $Path,
        [switch] $Force
    )

    if (-not ($Path | Test-Path)) {
        return
    }

    #Recursive call
    $ChildTestFolder = Join-Path -Path $Path -ChildPath $TestRunFolderName
    if (Test-Path -Path $ChildTestFolder) {
        Remove-TestingFolder -Path $ChildTestFolder
    }

    # So far only remove content for TestRunFolder named folders
    if (($Path | Split-Path -Leaf) -ne $TestRunFolderName) {
        if (-not $Force) {
            return
        }
    }

    if (Test-Path -Path $Path) {
        $local = Get-Item -Path $Path
        $local | Get-ChildItem -File | Remove-Item -Force
        $local | Get-ChildItem -Directory |  Remove-TestingFolder -Force
        $local | Remove-Item -Force -Recurse
    }
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

function New-TestingFolder {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)] [string] $Path,
        [Parameter()] [string] $Name,
        [switch] $PassThru
    )

    if ($Path -and !$Name) {
        $finalPath = $Path
    } else {
        if ([string]::IsNullOrWhiteSpace($Name))    { $Name    = (New-Guid).ToString()}
        if ([string]::IsNullOrWhiteSpace($Path))    { $Path    = '.' }

        $finalPath = $Path | Join-Path -ChildPath $Name
    }
    
    # if ($Path -and $Name) {
    #     $finalPath = $Path | Join-Path -ChildPath $Name
    # }
    
    # if (!$Path -and $Name) {
    #     $finalPath = '.' | Join-Path -ChildPath $Name
    # }
    
    # if (!$Path -and !$Name) {
    #     $finalPath = '.' | Join-Path -ChildPath (New-Guid).ToString()
    # }


    # Need to consolidate as mkdir behaves diferent on PC or Mac
    $result = New-Item -ItemType Directory -Path $finalPath

    Write-Verbose -Message "Created Diretory [ $result ] "

    if ($PassThru) {
        return $result
    }
}

function New-TestingFile {
    param(
        [Parameter(ValueFromPipeline)][string]$Path,
        [Parameter()][string]$Name,
        [Parameter()][string]$Content,
        [switch] $Hidden,
        [switch] $PassThru
    )

    if ([string]::IsNullOrWhiteSpace($Name))    { $Name    = ("{0}.txt" -f (New-Guid).ToString()) }
    if ([string]::IsNullOrWhiteSpace($Path))    { $Path    = '.' }
    if ([string]::IsNullOrWhiteSpace($Content)) { $Content = "random content" }

    $file = New-Item -ItemType File -Path $Path -Name $Name -Value $Content -Force

    if ($Hidden) {
        $file.Attributes = $file.Attributes -bxor [System.IO.FileAttributes]::Hidden
    }

    if ($PassThru) {
        return $file
    }
}

function Remove-TestingFile {
    param(
        [Parameter(ValueFromPipeline)][string]$Path,
        [Parameter()][string]$Name,
        [Parameter()][string]$Content,
        [switch] $Hidden
    )
    
    if ([string]::IsNullOrWhiteSpace($Path))    { $Path    = '.' }
    
    $target = ([string]::IsNullOrWhiteSpace($Name)) ? $Path : ($Path | Join-Path -ChildPath $Name)

    Assert-ItemExist -Path $target

    (Get-Item -Force -Path $target).Attributes = 0

    Remove-Item -Path $target

    Assert-itemNotExist -Path $target
} 

function GetRooTestingFolderPath{
    # get the first 6 char of a guid
    $random = (New-Guid).ToString().Substring(0,6)
    $rd = Get-Date -Format yyMMdd
    $path = Join-Path -Path "Temp:" -ChildPath ("Posh_Testing_{0}_{1}" -f $rd,$random)
    return $path
}