# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Stop a Neo4j Server Windows Service

.DESCRIPTION
Stop a Neo4j Server Windows Service

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server object

.EXAMPLE
Stop-Neo4jServer -Neo4jServer $ServerObject

Stop the Neo4j Windows Windows Service for the Neo4j installation at $ServerObject

.OUTPUTS
System.Int32
0 = Service was stopped and not running
non-zero = an error occured

.NOTES
This function is private to the powershell module

#>
function Stop-Neo4jServer
{
  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [pscustomobject]$Neo4jServer

  )

  begin
  {
  }

  process
  {
    $ServiceName = Get-Neo4jWindowsServiceName -Neo4jServer $Neo4jServer -ErrorAction Stop
    $Found = Get-Service -Name $ServiceName -ComputerName '.' -ErrorAction 'SilentlyContinue'
    if ($Found)
    {
      $prunsrv = Get-Neo4jPrunsrv -Neo4jServer $Neo4jServer -ForServerStop
      if ($prunsrv -eq $null) { throw "Could not determine the command line for PRUNSRV" }

      Write-Verbose "Stopping Neo4j service"
      $result = Invoke-ExternalCommand -Command $prunsrv.cmd -CommandArgs $prunsrv.args

      # Process the output
      if ($result.exitCode -eq 0) {
        Write-Host "Neo4j service stopped"
      } else {
        Write-Host "Neo4j service did not stop"
        # Write out STDERR if it did not stop
        Write-Host $result.capturedOutput
      }

      Write-Output $result.exitCode
    }
    else
    {
      Write-Host "Service stop failed - service '$ServiceName' not found"
      Write-Output 1
    }
  }

  end
  {
  }
}
