function Import-Template ($Path,$File,$Template,$Replaces){

    $null = New-Item -ItemType Directory -Force -Path $Path

    $script = Get-Content -Path ($PSScriptRoot  | Join-Path -ChildPath templates -AdditionalChildPath $Template)

    if ($Replaces) {
        $Replaces.Keys | ForEach-Object {
            $script = $script.Replace($_, $Replaces.$_)
        }
    }

    $script | Set-Content -Path (Join-Path -Path $Path -ChildPath $File)
}