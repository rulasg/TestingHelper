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

        # Extract last commit message from log to check body message
        $body= (git -C $Path log -1 --pretty=%B | out-string).Trim()
        Assert-AreEqual -Expected $MessageExpected -Presented $body -Comment "Git commit message"

        # Extarct last commit message from log to check author
        $author = git -C $Path log -1 --pretty='[%an][%ae]'
        Assert-AreEqual -Expected "[TestingHelper Agent][tha@sample.com]" -Presented $author -Comment "Git commit author"
    }
}