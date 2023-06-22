function Assert-ContainsPattern{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter(Mandatory)] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    $found = $false
    foreach($p in $Presented){
        if ($p -like $Expected) {
            $found = $true
            break
        }
    }

    Assert-IsTrue -Condition $found -Comment "Not found pattern [$Expected] in $Presented - $Comment "
}

function Assert-ContainsNotPattern{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter(Mandatory)] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    $found = $false
    foreach($p in $Presented){
        if ($p -like $Expected) {
            $found = $true
            break
        }
    }

    Assert-IsFalse -Condition $found -Comment "Found pattern [$Expected] in $Presented - $Comment"
}