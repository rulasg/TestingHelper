function TestingHelperTest_AddToModuleGitRepository_Init_PipeCalls_Folder{
    
    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -PassThru 
    $result | Assert-AddGitRepository

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -PassThru @WarningParameters
    Assert-Contains -Expected "Git repository already exists." -Presented $warningVar

}

function TestingHelperTest_AddToModuleGitRepository_Init_PipeCalls_Folder_Force{

    New-TestingFolder -Path "folderName"

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -PassThru
    $result | Assert-AddGitRepository

    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -Force -PassThru @WarningParameters
    Assert-Contains -Expected "Reinitialized existing Git repository." -Presented $warningVar
}

function TestingHelperTest_AddToModuleGitRepository_Init_PipeCalls_Folder_WhatIf_DoubleCall{

    $folder = New-TestingFolder -Path "folderName" -PassThru

    # WhatIf
    $result = $folder | Add-TT_ToModuleGitRepository  -Whatif @WarningParameters
    Assert-IsNull -Object $result
    Assert-Count -Expected 0 -Presented $warningVar
    
    # First call
    $result = $folder | Add-TT_ToModuleGitRepository  @WarningParameters
    Assert-IsNull -Object $result
    Assert-Count -Expected 0 -Presented $warningVar
    
    # Second call
    $result = $folder | Assert-AddGitRepository
    Assert-IsNull -Object $result
    Assert-Count -Expected 0 -Presented $warningVar
    
    # Second call Whatif
    $result = $folder | Add-TT_ToModuleGitRepository -whatif @WarningParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected "Git repository already exists." -Presented $warningVar
    
    # Second call -force -whatif
    $result = $folder | Add-TT_ToModuleGitRepository -whatif -force @WarningParameters
    Assert-IsNull -Object $result
    Assert-Count -Expected 0 -Presented $warningVar
    
    # Second call -force 
    $result = Get-Item -path "folderName" | Add-TT_ToModuleGitRepository -Force @WarningParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected "Reinitialized existing Git repository." -Presented $warningVar
}

function TestingHelperTest_AddToModuleGitCommit_PipeCalls_Folder{
    
    $folder = New-TestingFolder -Path "folderName" -PassThru

    $result = $folder | Add-TT_ToModuleGitCommit @ErrorParameters
    Assert-IsNull -Object $result
    Assert-Contains -Expected "Git repository does not exist. Use -Force or Add-ToModuleGitRepository to create it." -Presented $errorVar
    
    # -Force
    $result = $folder | Add-TT_ToModuleGitCommit -Force -Passthru @ErrorParameters
    $result | Assert-AddGitRepository 
    $result | Assert-AddGitCommit -MessageExpected "TH Init commit"
    
    # No Message
    $result | Add-TT_ToModuleGitCommit -PassThru @ErrorParameters
    $result | Assert-AddGitCommit -MessageExpected "TH Commit"

    # With Message
    $result | Add-TT_ToModuleGitCommit -Message "Some message to the commit" -PassThru @ErrorParameters
    $result | Assert-AddGitCommit -MessageExpected  "Some message to the commit" 
    
}

