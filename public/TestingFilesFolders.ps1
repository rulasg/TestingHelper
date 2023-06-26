
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
    
    # Need to consolidate as mkdir behaves diferent on PC or Mac
    $result = New-Item -ItemType Directory -Path $finalPath

    Write-Verbose -Message "Created Diretory [ $result ] "

    if ($PassThru) {
        return $result
    }
} Export-ModuleMember -Function New-TestingFolder

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
} Export-ModuleMember -Function Remove-TestingFolder

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
} Export-ModuleMember -Function New-TestingFile

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
} Export-ModuleMember -Function Remove-TestingFile
