function Get-DefaultsManifest {
    New-ModuleManifest -Path defaults.psd1 -RootModule defaults.psm1
    $defaultsManifest = Import-PowerShellDataFile -Path defaults.psd1 
    return $defaultsManifest
}

function Assert-AddModuleV3 {
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path,
        [Parameter()][hashtable]$Expected
    )
    
    $psdname = $Name + ".psd1"
    $psmName = $Name + ".psm1"

    $fullExpected = Get-DefaultsManifest
    
    # Update fullExpected with expected
    ForEach($key in $Expected.Keys) { $fullExpected[$key] = $Expected[$key]}

    #PSM1
    $psmPath = $Path | Join-Path -ChildPath $psmName
    Assert-ItemExist -Path $psmPath

    # public private
    Assert-ItemExist -Path ($Path | Join-Path -ChildPath "public") -Comment "public folder"
    Assert-ItemExist -Path ($Path | Join-Path -ChildPath "private") -Comment "private folder"

    #PSD1
    $psdPath = $Path | Join-Path -ChildPath  $psdname
    Assert-ItemExist -Path $psdPath

    #manifest
    $presented = Import-PowerShellDataFile -Path $psdPath

    # GUID
    # PrivateData
    Assert-AreEqual -Expected $fullExpected.AliasesToExport   -Presented $presented.AliasesToExport   -Comment "Manifest AliasesToExport"
    Assert-AreEqual -Expected $fullExpected.Author            -Presented $presented.Author            -Comment "Manifest Author"
    Assert-AreEqual -Expected $fullExpected.CmdletsToExport   -Presented $presented.CmdletsToExport   -Comment "Manifest CmdletsToExport"
    Assert-AreEqual -Expected $fullExpected.VariablesToExport -Presented $presented.VariablesToExport -Comment "Manifest VariablesToExport"
    Assert-AreEqual -Expected $fullExpected.ModuleVersion     -Presented $presented.ModuleVersion     -Comment "Manifest ModuleVersion"
    Assert-AreEqual -Expected $fullExpected.Copyright         -Presented $presented.Copyright         -Comment "Manifest Copyright"
    Assert-AreEqual -Expected $fullExpected.CompanyName       -Presented $presented.CompanyName       -Comment "Manifest CompanyName"
    
    # Not Strings
    Assert-AreEqual -Expected ($fullExpected.FunctionsToExport | ConvertTo-Json) -Presented ($presented.FunctionsToExport | ConvertTo-Json) -Comment "Manifest FunctionsToExport"

    #Exceptions
    Assert-AreEqual -Expected "$Name.psm1" -Presented $presented.RootModule -Comment "Manifest RootModule"
    Assert-AreEqual -Expected ($fullExpected.Description ?? "") -Presented ($presented.Description ?? "") -Comment "Manifest Description"

    Write-AssertionSectionEnd
}
