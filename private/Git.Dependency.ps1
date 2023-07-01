
# Will return the git string or null for error.
# Error string will be sabed on $GITLASTERROR

$GITLASTERROR = $null


# function Initialize-GitRepoConfiguration {
#     [CmdletBinding()]
#     param(
#         [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
#         [Alias("PSPath")][ValidateNotNullOrEmpty()]
#         [string] $Path
#     )
#     process{
#         #check if its null or empty
#         if([string]::IsNullOrWhiteSpace($result)){
#             if ($PSCmdlet.ShouldProcess("git config user.email", "Init to [you@example.com] ")) {
#                 $result = git -C $Path config user.email
#                 if($LASTEXITCODE -ne 0){
#                     $GITLASTERROR = "Git config user.email failed"
#                     return $null
#                 }
#             }
#         }
#         #check if its null or empty
#         if([string]::IsNullOrWhiteSpace($result)){
#             if ($PSCmdlet.ShouldProcess("git config user.name", "Init to [Your Name]")) {
#                 $result = git -C $Path config user.name
#                 if($LASTEXITCODE -ne 0){
#                     $GITLASTERROR = "Git config user.name failed"
#                     return $null
#                 }
#             }
#         }
#         return $true
#     }
# }

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

    # Initialize git repository
    $result = git -C $Path init --initial-branch="main"

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
    $result = git -C $Path add .

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git staginig failed - $result"
        return $null
    }

    # $result = Initialize-GitRepoConfiguration -Path $Path
    # if(!$result){
    #     $GITLASTERROR = "Git configuration failed - $GITLASTERROR"
    #     return $null
    # }
    
    # Commit all changes depending on auther configuration
    # $gitUserName = git -C $Path config user.name 
    # if(![string]::IsNullOrWhiteSpace($gitUserName)){
    #     Write-Verbose "Git user.name is $gitUserName"
    #     $result = git -C $Path commit --allow-empty  -m $Message
    # } else {
    #     Write-Verbose "Git user.name is empty. Using fake author TMAgente"
    #     $result = git -C $Path commit --allow-empty  -m $Message --author="TMAgente <>"
    #     # $result = git -C $Path commit --allow-empty  -m $Message --author="TMAgente <tmagent@company.com>"
    # }

    # We will author all commits with a fake user
    $result = git -C $Path commit --allow-empty  -m $Message --author="TestingHelper Agent <tha@sample.com>"

    # check the result of git call
    if($LASTEXITCODE -ne 0){
        $GITLASTERROR = "Git commit failed - $result"
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