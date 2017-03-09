<#
        .SYNOPSIS
        Extract a list of PackageIDs from 'packages.config' found in a folder
        .DESCRIPTION
        Searches a directory to recursively for 'packages.config' files
        and extracts a unique list of Nuget Package IDs
        .OUTPUTS
        An array of Nuget PackageID strings
#>
#requires -Version 2
function Get-NugetPackageIds
{
    [CmdletBinding()]
    param(
        # A list of 'packages.config' files
        [Parameter(Mandatory = $true)]
        [FileInfo[]] $PackageConfigs,

        # A list of packages that will be upgraded.
        # Wildcards can be used.
        # Defaults to Redgate.*
        [string[]] $IncludedPackages = @('Redgate.*'),

        # A list of packages we do NOT want to update.
        # Shame on you if you're using this! (but yeah it can be handy :blush:)
        [string[]] $ExcludedPackages
    )

    $AllPackages = $PackageConfigs | ForEach-Object {
        ([Xml]($_ | Get-Content)).packages.package.id
    } | Select-Object -Unique

    $FilteredPackageIDs = @()
    foreach($pattern in $IncludedPackages) {
        $FilteredPackageIDs += $AllPackages | Where-Object { $_ -like $pattern}
    }

    if($ExcludedPackages) {
        # Remove execluded packages if any
        $FilteredPackageIDs = $FilteredPackageIDs | Where-Object { $ExcludedPackages -notcontains $_ }
    }

    return $FilteredPackageIDs | Select-Object -Unique | Sort-Object
}
