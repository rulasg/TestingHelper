<#
.SYNOPSIS
    Create a tag and release on GitHub

.DESCRIPTION
    Create a tag on the repo and a release to that tag on GitHub remote repo.
    This script works very well with GitHub Actions workflow that run on release creation.

    Check the following workflow as an example: 
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/.github/workflows/publish_module_on_release.yml


.PARAMETER VersionTag
    Tag to create (Sample: v10.0.01-alpha). This is the same tag that will be used for the release.

.PARAMETER Force
    Force the script to run without confirmation.

.PARAMETER CreateTag
    Create the tag on the repo. If not specified, the script will only create the release.

.EXAMPLE
    .\release.ps1 -VersionTag v10.0.01-alpha

    Create a release on the existing tag v10.0.01-alpha.

.EXAMPLE
    .\release.ps1 -VersionTag v10.0.01-alpha -CreateTag

    Create a release on the existing tag v10.0.01-alpha and create the tag on the repo.

.EXAMPLE
    .\release.ps1 -VersionTag v10.0.01-alpha -CreateTag -Force

    Create tag and create release without confirmation. 
    
.LINK
    https://raw.githubusercontent.com/rulasg/DemoPsModule/main/release.ps1
#>

[cmdletbinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    # Update the module manifest with the version tag (Sample: v10.0.01-alpha)
    [Parameter(Mandatory)] [string]$VersionTag,
    [Parameter()] [switch]$Force,
    [Parameter()] [switch]$CreateTag,
    [Parameter()] [switch]$NotPreRelease
)

# Confirm if not forced
if ($Force -and -not $Confirm){
    $ConfirmPreference = 'None'
}

if ($CreateTag) {
    if ($PSCmdlet.ShouldProcess($VersionTag, "git tag creation")) {
        git tag -a $VersionTag -m "Release tag" -s ; git push --tags
    }
}

if ($PSCmdlet.ShouldProcess($VersionTag, "gh release create")) {

    if ($NotPreRelease) {
        gh release create $VersionTag --generate-notes --verify-tag --title "Release $VersionTag"  

    } else {
        gh release create $VersionTag --generate-notes --verify-tag --title "Release $VersionTag (PreRelease)"  --prerelease
    }
}