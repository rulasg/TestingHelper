# Adds git repository to the module
function Add-ToModuleGitRepository{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter(ValueFromPipelineByPropertyName)][switch]$Force,
        [Parameter(ValueFromPipelineByPropertyName)][Switch]$Passthru
    )

    process{
        $Path = NormalizePath -Path:$Path ?? return $null
        $ret = ReturnValue -Path $Path -Force:$Force -Passthru:$Passthru

        # check if git was initialized before on this folder

        if((Test-GitRepository -Path $Path) -and (!$Force)){
            Write-Warning "Git repository already exists."
            return $ret
        }

        if ($PSCmdlet.ShouldProcess($Path, "Git init")) {

            $result = Invoke-GitRepositoryInit -Path $Path
        } else {
            # Fake a success run
            $result = "Initialized empty Git repository in"
        }

        if(!$result){
            Write-Error "Git init failed. $GITLASTERROR"
            return $ret
        }

        # Write warning of the execution if needed
        # SUCCESS "Initialized empty Git repository in $Path/.git/"
        # ALREADY "Reinitialized existing Git repository in $Path/.git/"
        if (!($result.StartsWith("Initialized empty Git repository in"))) {

            if($result.StartsWith("Reinitialized existing Git repository in") -and $Force){
                Write-Warning "Reinitialized existing Git repository."

            } else {
                Write-Warning "Git init may have failed. Please check the output"
            }
        }            

        return $ret

    }
} Export-ModuleMember -Function Add-ToModuleGitRepository

function Add-ToModuleGitCommit{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("PSPath")][ValidateNotNullOrEmpty()]
        [string] $Path,
        [Parameter(ValueFromPipelineByPropertyName)][switch]$Force,
        [Parameter(ValueFromPipelineByPropertyName)][Switch]$Passthru,
        [Parameter()][string]$Message
    )

    process{
        $Path = NormalizePath -Path:$Path ?? return $null
        $ret = ReturnValue -Path $Path -Force:$Force -Passthru:$Passthru

        # no Git Repository and no Force
        if(!(Test-GitRepository -Path $Path) ){
            #check for force
            if(!$Force){
                Write-Error "Git repository does not exist. Use -Force or Add-ToModuleGitRepository to create it."
                return $ret
            } else {
                # Create Git Repository
               Add-ToModuleGitRepository -Path $Path
               $justCreated = $true
               # no need to control errors. Call will display them
            }
        }

        # Set messsage if not provided
        if ([string]::IsNullOrEmpty($Message)) {
            $Message = $justCreated ? "TH Init commit" : "TH Commit"<# Action to perform if the condition is true #>
        }
        

        $result = Invoke-GitRepositoryCommit -Path $Path -Message $Message

        if(!$result){
            Write-Error "Git commit failed. $GITLASTERROR"
            return $ret
        }

        # Write warning of the execution if needed

        return $ret
    }
} Export-ModuleMember -Function Add-ToModuleGitCommit