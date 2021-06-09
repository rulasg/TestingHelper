
Write-Host "Loading TestingHelperTestHelper ..." -ForegroundColor DarkCyan

# Windows and MacOS uses different separatod char on PsModulePath
$splitchar = ($Env:OS -eq 'Windows_NT') ? ';' : ':'

function Add-PSModulePath {
    param (
        [parameter(ValueFromPipeline)][string] $Path
    )

    $env:PSModulePath+= ("$splitChar{0}" -f ( Resolve-Path -Path:$Path ))
    
} Export-ModuleMember -Function Add-PSModulePath

function Get-PSModulePath {
    
    $env:PSModulePath.Split($splitchar)

} Export-ModuleMember -Function Get-PSModulePath