# Git Repository
function Assert-AddGitRepository{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )
    process{
        $Path = $Path | Convert-Path

        Assert-ItemExist -Path ($Path | Join-Path -ChildPath ".git") -Comment ".git"
    }
}

function Assert-AddGitCommit{
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter(Mandatory)][string]$MessageExpected 
    )
    process{
        $Path = $Path | Convert-Path

        # Extract last commit message from log.
        $messageList= git -C $Path log -1 --pretty=%B 

        
        $lastMessage = ($messageList | Out-String).Trim()

        Assert-AreEqual -Expected $MessageExpected -Presented $lastMessage -Comment "Git commit message"
    }
}