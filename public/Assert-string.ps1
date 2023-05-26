function Assert-AreEqualSecureString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter(Mandatory)] [securestring] $Presented,
        [Parameter()] [string] $Comment

    )

    $pss = $Presented | ConvertFrom-SecureString -AsPlainText

    Assert-AreEqual -Expected $Expected -Presented $pss -Comment ("SecureString - " + $Comment)
}

function Assert-StringIsNotNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][string] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsFalse -Condition ([string]::IsNullOrEmpty($Presented))-Comment ("String not null or empty -" + $Comment)
}

function Assert-StringIsNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][string] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsTrue -Condition ([string]::IsNullOrEmpty($Presented))-Comment ("String null or empty -" + $Comment)
}