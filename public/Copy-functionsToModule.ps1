
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

    $sourceTestPublic = $Source | Join-Path -ChildPath $($sourceModuleName + 'Test') -AdditionalChildPath 'public'
    $sourceTestPrivate = $Source | Join-Path -ChildPath $($sourceModuleName + 'Test') -AdditionalChildPath 'private'

    $destinationPublic = $Destination | Join-Path -ChildPath 'public'
    $destinationPrivate = $Destination | Join-Path -ChildPath 'private'

    $destinationTestPublic = $Destination | Join-Path -ChildPath $($destinationModuleName + 'Test') -AdditionalChildPath 'public'
    $destinationTestPrivate = $Destination | Join-Path -ChildPath $($destinationModuleName + 'Test') -AdditionalChildPath 'private'

    Copy-Item -Path $sourcePublic/* -Destination $destinationPublic -Recurse
    Copy-Item -Path $sourcePrivate/* -Destination $destinationPrivate -Recurse

    Copy-Item -Path $sourceTestPublic/* -Destination $destinationTestPublic -Recurse
    Copy-Item -Path $sourceTestPrivate/* -Destination $destinationTestPrivate -Recurse

} Export-ModuleMember -Function Copy-FunctionsToModule

