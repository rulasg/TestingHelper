
function Initialize-GitRepoConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path
    )

    process{
        #check if its null or empty
        if([string]::IsNullOrWhiteSpace($result)){
            if ($PSCmdlet.ShouldProcess("git config user.email", "Init to [you@example.com] ")) {
                $result = git config user.email
            }
        }

        #check if its null or empty
        if([string]::IsNullOrWhiteSpace($result)){
            if ($PSCmdlet.ShouldProcess("git config user.name", "Init to [Your Name]")) {
                $result = git config user.name∫
            }
        }
    }

}