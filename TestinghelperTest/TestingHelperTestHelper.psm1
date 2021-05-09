
Write-Host "Loading TestingHelperTestHelper ..." -ForegroundColor DarkCyan

function Add-PSModulePath {
    param (
        [parameter(ValueFromPipeline)][string] $Path
    )
    
    # Windows and MacOS uses different separatod char on PsModulePath
    if ($Env:OS -eq 'Windows_NT') {
        $env:PSModulePath+= (';{0}' -f ( Resolve-Path -Path:$Path ))
    }
    else {
        $env:PSModulePath+= (':{0}' -f ( Resolve-Path -Path:$Path ))
    }
} Export-ModuleMember -Function Add-PSModulePath