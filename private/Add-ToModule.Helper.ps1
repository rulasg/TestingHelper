
# Create the return value to allow AddToModule pipe chaining
function ReturnValue($Path,$Force, $Passthru){
    # create object with the two parameters as properties

    if($Passthru){
        return [pscustomobject]@{
            Path = $Path
            Force = $Force
            Passthru = $Passthru
         }
    } 
}

# Normalize $Path and returns $null if not valid
# If $Path is a file, returns the parent folder
# If $Path is $null or empty, returns the current folder
# Path needs to be a valid path
function NormalizePath($Path){
    # Path returned should be the folder where the module is located.
    
    # Aceot local folder as default
    $Path = [string]::isnullorwhitespace($Path) ? '.' : $Path
    
    # We may input the RootModule as if we pipe Get-Module command.
    # check if $Path is a file and get the parent of it
    if(Test-Path -Path $Path -PathType Leaf){
        $ret = $Path | Split-Path -Parent
    } else {
        $ret = $Path
    }

    return  $ret | Convert-Path
}