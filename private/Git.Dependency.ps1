
# Will return the git string or null for error.
# Error string will be sabed on $GITLASTERROR

$GITLASTERROR = $null

# Initializae git repository
function script:Invoke-GitRepositoryInit{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    # check if git is installed
    $gitPath = Get-Command -Name git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

    if(!$gitPath){
        $GITLASTERROR =  "Git is not installed"
        return $null
    }

    $result = git init $Path

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git init failed"
        return $null
    }

    $GITLASTERROR = $null
    return $result
}

function script:Test-GitRepository{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    $gitPath = $Path | Join-Path -ChildPath ".git"
    
    $ret = Test-Path -Path $gitPath

    return $ret
}