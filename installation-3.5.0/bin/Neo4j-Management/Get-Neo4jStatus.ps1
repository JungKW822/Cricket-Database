# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Retrieves the status for the Neo4j Windows Service

.DESCRIPTION
Retrieves the status for the Neo4j Windows Service

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server object

.EXAMPLE
Get-Neo4jStatus -Neo4jServer $ServerObject

Retrieves the status of the Windows Service for the Neo4j database at $ServerObject

.OUTPUTS
System.Int32
0 = Service is running
3 = Service is not installed or is not running

.NOTES
This function is private to the powershell module

#>
function Get-Neo4jStatus
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [pscustomobject]$Neo4jServer
  )

  begin
  {
  }

  process {
    $ServiceName = Get-Neo4jWindowsServiceName -Neo4jServer $Neo4jServer -ErrorAction Stop
    $neoService = $null
    try {
      $neoService = Get-Service -Name $ServiceName -ErrorAction Stop
    }
    catch {
      Write-Host "The Neo4j Windows Service '$ServiceName' is not installed"
      return 3
    }

    if ($neoService.Status -eq 'Running') {
      Write-Host "Neo4j is running"
      return 0
    }
    else {
      Write-Host "Neo4j is not running.  Current status is $($neoService.Status)"
      return 3
    }
  }

  end
  {
  }
}
