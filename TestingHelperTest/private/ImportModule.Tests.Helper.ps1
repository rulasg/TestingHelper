
function Remove-ImportedModule($Module){
        # if ModuleName module is loaded, remove it
    if(Get-Module -Name $Module -ListAvailable){
        Remove-Module -Name $Module -Force
    }
}