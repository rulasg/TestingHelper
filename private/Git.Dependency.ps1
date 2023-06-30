
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

    $result = git -C $Path init

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git init failed"
        return $null
    }

    $GITLASTERROR = $null
    return $result
}

# Create a commit with actual changes
function script:Invoke-GitRepositoryCommit{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Message
    )

    # check if git is installed
    $gitPath = Get-Command -Name git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

    if(!$gitPath){
        $GITLASTERROR =  "Git is not installed"
        return $null
    }

    # Stage all changes
    $null = git -C $Path add .

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git staginig failed"
        return $null
    }

    # Commit all changes
    $result = git -C $Path commit --allow-empty  -m $Message

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git commit failed"
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