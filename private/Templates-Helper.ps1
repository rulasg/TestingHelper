function Import-Template {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$File,
        [Parameter(Mandatory)][string]$Template,
        [Parameter()][hashtable]$Replaces
    )

    # test if $path exists
    if(!($Path | Test-Path)){
        if ($PSCmdlet.ShouldProcess($Path, "New-Item -Directory -Force")) {
            $null = New-Item -ItemType Directory -Force -Path $Path
        }
    }

    $content = Get-Content -Path ($PSScriptRoot  | Join-Path -ChildPath templates -AdditionalChildPath $Template)

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
