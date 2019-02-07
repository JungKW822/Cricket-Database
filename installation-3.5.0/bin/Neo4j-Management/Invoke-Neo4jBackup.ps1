# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Invokes Neo4j Backup utility

.DESCRIPTION
Invokes Neo4j Backup utility

.PARAMETER CommandArgs
The remaining command line arguments to pass to the Neo4j Backup

.OUTPUTS
System.Int32
0 = Success
non-zero = an error occured

.NOTES
Only supported on version 3.x Neo4j Enterprise Edition databases

#>
function Invoke-Neo4jBackup
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $false,ValueFromRemainingArguments = $true)]
    [object[]]$CommandArgs = @()
  )

  begin
  {
  }

  process
  {
    try {
      return [int](Invoke-Neo4jUtility -Command 'Backup' -CommandArgs $CommandArgs -ErrorAction 'Stop')
    }
    catch {
      Write-Error $_
      return 1
    }
  }

  end
  {
  }
}
