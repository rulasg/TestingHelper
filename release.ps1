<#
.SYNOPSIS
    Create a tag and release on GitHub

.DESCRIPTION
    Create a tag on the repo and a release to that tag on GitHub remote repo.
    This script works very well with GitHub Actions workflow that run on release creation.

.PARAMETER VersionTag
    Tag to create (Sample: v10.0.01-alpha). This is the same tag that will be used for the release.

.PARAMETER Force
    Force the script to run without confirmation.

.EXAMPLE
    .\release.ps1 -VersionTag v10.0.01-alpha

.EXAMPLE
    .\release.ps1 -VersionTag v10.0.01-alpha -Force

.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/release.ps1
#>

[cmdletbinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    # Update the module manifest with the version tag (Sample: v10.0.01-alpha)
    [Parameter(Mandatory)] [string]$VersionTag,
    [Parameter()] [switch]$Force
)

# Confirm if not forced
if ($Force -and -not $Confirm){
    $ConfirmPreference = 'None'
}

if ($PSCmdlet.ShouldProcess($VersionTag, "git tag creation")) {
    git tag -a $VersionTag -m "Release tag" -s ; git push --tags
}

if ($PSCmdlet.ShouldProcess($VersionTag, "gh release create")) {
    gh release create $VersionTag --prerelease --generate-notes --verify-tag --title "Release $VersionTag"  
}