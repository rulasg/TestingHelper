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

# function Import-Template ($Path,$File,$Template,$Replaces){

#     # test if $path exists
#     if(!($Path | Test-Path)){
#         $null = New-Item -ItemType Directory -Force -Path $Path
#     }

#     $destinationPath = $Path | Join-Path -ChildPath $File

#     # test if $destinationPath exists
#     if($destinationPath | Test-Path){
#         Write-Error "$File already exists."
#         return $false
#     }

#     $script = Get-Content -Path ($PSScriptRoot  | Join-Path -ChildPath templates -AdditionalChildPath $Template)

#     if ($Replaces) {
#         $Replaces.Keys | ForEach-Object {
#             $script = $script.Replace($_, $Replaces.$_)
#         }
#     }

#     try {
#         $script | Set-Content -Path $destinationPath
#         Write-Information -MessageData "Create file [$destinationPath]"
#     }
#     catch {
#         Write-Error -Message ("Error creating the file. " + $_.Exception.Message)
#     }

#     return $true
# }