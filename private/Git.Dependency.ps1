
# Will return the git string or null for error.
# Error string will be sabed on $GITLASTERROR

$GITLASTERROR = $null

# Reset git configuration
function Reset-GitRepoConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )

    begin{
        $userName = "TestingHelper Agent"
        $userEmail = "tha@sample.com"
        $commitGpgSign = "false"
    }

    process{
        if ($PSCmdlet.ShouldProcess("git config user.email", "Init to [you@example.com] ")) {
            $result1 = git -C $Path config user.email $userEmail
            if($LASTEXITCODE -ne 0){
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
                $GITLASTERROR = "Git config user.email failed - $result1"
                return $null
            }
        }

        if ($PSCmdlet.ShouldProcess("git config user.name", "Init to [Your Name]")) {
            $result2 = git -C $Path config user.name $userName
            if($LASTEXITCODE -ne 0){
                $GITLASTERROR = "Git config user.name failed - $result2"
                return $null
            }
        }

        if ($PSCmdlet.ShouldProcess("git config commit.gpgsign", "Init to $commitGpgSign")) {
            $result3 = git -C $Path config commit.gpgsign $commitGpgSign
            if($LASTEXITCODE -ne 0){
                $GITLASTERROR = "Git config commit.gpgsign failed - $result3"
                return $null
            }
        }

        return $true
    }
}

# Initializae git repository
function script:Invoke-GitRepositoryInit{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    # check if git is installed
    $gitPath = Get-Command -Name git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if(!$gitPath){
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Scope='Function')]
        $GITLASTERROR =  "Git is not installed"
        return $null
    }

    # Initialize git repository
    # Silence warnings from git STDERR stream. 2>$null
    $result = git -C $Path init --initial-branch="main" 2>$null

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git init failed."
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

    # Reset git configuration.
    $gitReset = Reset-GitRepoConfiguration -Path $Path
    if(!$gitReset){
        $GITLASTERROR =  "Git Resetting configuration failed - $GITLASTERROR"
        return $null
    }

    # check if git is installed
    $gitPath = Get-Command -Name git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if(!$gitPath){
        $GITLASTERROR =  "Git is not installed"
        return $null
    }

    # Stage all changes
    $result = git -C $Path add .
    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git staginig failed - $result"
        return $null
    }

    # Commit
    $result = git -C $Path commit --allow-empty  -m $Message 
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git commit failed - $result"
        return $null
    }

    $GITLASTERROR = $null
    return $result
}

# Check if the folder is a git repository
function script:Test-GitRepository{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )
    # check if we are on a git folder
    return ((git -C $Path rev-parse --is-inside-work-tree 2>$null) -eq "true")
}