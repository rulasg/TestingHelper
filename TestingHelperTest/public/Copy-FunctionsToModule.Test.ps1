
function TestingHelperTest_FunctionsToModule_Copy{

    New-ModuleV3 -name sourceModule -AddTesting
    New-ModuleV3 -name destinationModule -AddTesting

    New-TestingFile -Name Function1.ps1 -Path sourceModule/public
    New-TestingFile -Name Function6.txt -Path sourceModule/private/childFolder
    New-TestingFile -Name Function2.ps1 -Path sourceModule/private
    New-TestingFile -Name Function3.ps1 -Path sourceModule/Test/public
    New-TestingFile -Name Function4.ps1 -Path sourceModule/Test/private

    Copy-TT_FunctionsToModule -Source sourceModule -Destination destinationModule

    Assert-ItemExist -path destinationModule/public/Function1.ps1
    Assert-ItemExist -path destinationModule/private/Function2.ps1
    Assert-ItemExist -path destinationModule/private/childFolder/Function6.txt

    Assert-ItemExist -path destinationModule/Test/public/Function3.ps1
    Assert-ItemExist -path destinationModule/Test/private/Function4.ps1

}

function TestingHelperTest_FunctionsToModule_Copy_FilesExist{

    New-ModuleV3 -name sourceModule -AddTesting
    New-ModuleV3 -name destinationModule -AddTesting

    New-TestingFile -Name Function1.ps1 -Content 'Function1 source' -Path sourceModule/public
    New-TestingFile -Name Function6.txt -Content 'Function6 source' -Path sourceModule/private/childFolder
    New-TestingFile -Name Function2.ps1 -Content 'Function2 source' -Path sourceModule/private
    New-TestingFile -Name Function3.ps1 -Content 'Function3 source' -Path sourceModule/Test/public
    New-TestingFile -Name Function4.ps1 -Content 'Function4 source' -Path sourceModule/Test/private

    # Adding files on destination
    New-TestingFile -Name Function1.ps1 -Content 'Function1 destination' -Path destinationModule/public
    New-TestingFile -Name Function6.txt -Content 'Function6 destination' -Path destinationModule/private/childFolder
    New-TestingFile -Name Function3.ps1 -Content 'Function3 destination' -Path destinationModule/Test/public

    Copy-TT_FunctionsToModule -Source sourceModule -Destination destinationModule @InfoParameters

    Assert-AreEqual -Expected 'Function1 source' -Presented $(Get-Content -Path destinationModule/public/Function1.ps1)
    Assert-AreEqual -Expected 'Function6 source' -Presented $(Get-Content -Path destinationModule/private/childFolder/Function6.txt)
    Assert-AreEqual -Expected 'Function3 source' -Presented $(Get-Content -Path destinationModule/Test/public/Function3.ps1)
}
