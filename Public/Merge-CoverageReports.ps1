<#
.SYNOPSIS
  Merge multiple dotcover coverage reports into a single report.
.DESCRIPTION
  Find all the *.coverage.snap in a folder and merge them together using
    1 dotcover merge
    2 dotcover zip
  If running within Teamcity, let Teamcity know where the merged coverage snapshot is.
  If outside of teamcity use 'dotcover report' to create a html report for human beings to read.
#>
function Merge-CoverageReports {
  [CmdletBinding()]
  param(
    # The folder containing the coverage reports to be merged.
    [Parameter(Mandatory=$true)]
    [string] $OutputDir
  )

  $DotCoverPath = Get-DotCoverExePath

  $MergedSnapshotPath = "$OutputDir\coverage.report.merged"
  $snapshots = (Get-ChildItem $OutputDir -Filter *.coverage.snap).FullName -join ';'

  Execute-Command $DotCoverPath @('merge', "/Source=`"$snapshots`"", "/Output=`"$MergedSnapshotPath`"")
  Execute-Command $DotCoverPath @('zip', "/Source=`"$MergedSnapshotPath`"", "/Output=`"$MergedSnapshotPath.zip`"")

  if( $env:TEAMCITY_VERSION -eq $null ) {
    # Create an HTML report if running outside of Teamcity to help with debugging
    Execute-Command $DotCoverPath @('report', "/Source=`"$MergedSnapshotPath.zip`"", "/Output=`"$OutputDir\report.html`"", '/reporttype=HTML')
  } else {
    # Let Teamcity know where the report is.
    TeamCity-ImportDotNetCoverageResult 'dotcover' "$MergedSnapshotPath.zip"
  }
}
