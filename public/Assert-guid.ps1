function Assert-IsGuid{
    param(
        [string] $Presented
    )
    try {
        Assert-IsNotNull -Object (New-Object -TypeName System.Guid -ArgumentList $Presented)
    }
    catch {
        Assert -Condition $false -Comment "String is not a valid Guid"
    }
}