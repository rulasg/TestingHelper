# Imports a template to a file and replace content if $Force
function Import-Template {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$File,
        [Parameter(Mandatory)][string]$Template,
        [Parameter()][hashtable]$Replaces,
        [Parameter()][switch]$Force
    )

    $destination = Join-Path -Path $Path -ChildPath $File

    if (($destination | Test-Path) -and !$Force) {
            Write-Warning -Message "File $destination already exists. Use -Force to overwrite"
            return $false
    } 

    # test if $path exists
    if(!($Path | Test-Path)){
        if ($PSCmdlet.ShouldProcess($Path, "New-Item -Directory -Force")) {
            $null = New-Item -ItemType Directory -Force -Path $Path
        }
    }

    $templatePath = $PSScriptRoot  | Join-Path -ChildPath templates -AdditionalChildPath $Template
    $content = Get-Content -Path $templatePath

    if ($Replaces) {
        $Replaces.Keys | ForEach-Object {
            $content = $content.Replace($_, $Replaces.$_)
        }
    }

    $destination = Join-Path -Path $Path -ChildPath $File
    if ($PSCmdlet.ShouldProcess($destination, "Set-Content")) {
        $content | Set-Content -Path $destination
    }
}

# function Add-FileFromTemplate {
#     [CmdletBinding(SupportsShouldProcess)]
#     param(
#         [Parameter(Mandatory)][string]$Path,
#         [Parameter(Mandatory)][string]$File,
#         [Parameter(Mandatory)][string]$Template,
#         [Parameter()][hashtable]$Replaces,
#         [Parameter()][switch]$Force
#     )

#     $destination = Join-Path -Path $Path -ChildPath $File

#     if (($destionation | Test-Path) -and !$Force) {
#             Write-Warning -Message "File $destination already exists. Use -Force to overwrite"
#             return $false
#     } 
    
#     # Import will create File and folder and overwrite if exists
#     Import-Template -Path $Path -File $File -Template $Template -Replaces $Replaces
# }