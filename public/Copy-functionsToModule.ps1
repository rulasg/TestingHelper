
function Copy-FunctionsToModule {
    param(
        [Parameter(Mandatory,Position=0)][string]$Source,
        [Parameter(Mandatory,Position=1)][string]$Destination
    )

    $Source = Convert-Path $Source
    $Destination = Convert-Path $Destination

    $sourceModuleName = $Source | Split-Path -Leaf
    $destinationModuleName = $Destination | Split-Path -Leaf

    $sourcePublic = $Source | Join-Path -ChildPath 'public'
    $sourcePrivate = $Source | Join-Path -ChildPath 'private'

    $sourceTestPublic = $Source | Join-Path -ChildPath 'Test' -AdditionalChildPath 'public'
    $sourceTestPrivate = $Source | Join-Path -ChildPath  'Test' -AdditionalChildPath 'private'

    $destinationPublic = $Destination | Join-Path -ChildPath 'public'
    $destinationPrivate = $Destination | Join-Path -ChildPath 'private'

    $destinationTestPublic = $Destination | Join-Path -ChildPath 'Test' -AdditionalChildPath 'public'
    $destinationTestPrivate = $Destination | Join-Path -ChildPath 'Test' -AdditionalChildPath 'private'

    Copy-Item -Path $sourcePublic/* -Destination $destinationPublic -Recurse -Force
    Copy-Item -Path $sourcePrivate/* -Destination $destinationPrivate -Recurse -Force

    Copy-Item -Path $sourceTestPublic/* -Destination $destinationTestPublic -Recurse -Force
    Copy-Item -Path $sourceTestPrivate/* -Destination $destinationTestPrivate -Recurse -Force

} Export-ModuleMember -Function Copy-FunctionsToModule

