# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Invokes a command which manipulates a Neo4j Server e.g Start, Stop, Install and Uninstall

.DESCRIPTION
Invokes a command which manipulates a Neo4j Server e.g Start, Stop, Install and Uninstall.  

Invoke this function with a blank or missing command to list available commands

.PARAMETER Command
A string of the command to run.  Pass a blank string for the help text

.EXAMPLE
Invoke-Neo4j

Outputs the available commands

.EXAMPLE
Invoke-Neo4j status -Verbose

Gets the status of the Neo4j Windows Service and outputs verbose information to the console.

.OUTPUTS
System.Int32
0 = Success
non-zero = an error occured

.NOTES
Only supported on version 3.x Neo4j Community and Enterprise Edition databases

#>
function Invoke-Neo4j
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $false,ValueFromPipeline = $false,Position = 0)]
    [string]$Command = ''
  )

  begin
  {
  }

  process
  {
    try
    {
      $HelpText = "Usage: neo4j { console | start | stop | restart | status | install-service | uninstall-service | update-service } < -Verbose >"

      # Determine the Neo4j Home Directory.  Uses the NEO4J_HOME environment variable or a parent directory of this script
      $Neo4jHome = Get-Neo4jEnv 'NEO4J_HOME'
      if (($Neo4jHome -eq $null) -or (-not (Test-Path -Path $Neo4jHome))) {
        $Neo4jHome = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
      }
      if ($Neo4jHome -eq $null) { throw "Could not determine the Neo4j home Directory.  Set the NEO4J_HOME environment variable and retry" }
      Write-Verbose "Neo4j Root is '$Neo4jHome'"

      $thisServer = Get-Neo4jServer -Neo4jHome $Neo4jHome -ErrorAction Stop
      if ($thisServer -eq $null) { throw "Unable to determine the Neo4j Server installation information" }
      Write-Verbose "Neo4j Server Type is '$($thisServer.ServerType)'"
      Write-Verbose "Neo4j Version is '$($thisServer.ServerVersion)'"
      Write-Verbose "Neo4j Database Mode is '$($thisServer.DatabaseMode)'"

      switch ($Command.Trim().ToLower())
      {
        "help" {
          Write-Host $HelpText
          return 0
        }
        "console" {
          Write-Verbose "Console command specified"
          return [int](Start-Neo4jServer -Console -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "start" {
          Write-Verbose "Start command specified"
          return [int](Start-Neo4jServer -Service -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "stop" {
          Write-Verbose "Stop command specified"
          return [int](Stop-Neo4jServer -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "restart" {
          Write-Verbose "Restart command specified"

          $result = (Stop-Neo4jServer -Neo4jServer $thisServer -ErrorAction Stop)
          if ($result -ne 0) { return $result }
          return (Start-Neo4jServer -Service -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "status" {
          Write-Verbose "Status command specified"
          return [int](Get-Neo4jStatus -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "install-service" {
          Write-Verbose "Install command specified"
          return [int](Install-Neo4jServer -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "uninstall-service" {
          Write-Verbose "Uninstall command specified"
          return [int](Uninstall-Neo4jServer -Neo4jServer $thisServer -ErrorAction Stop)
        }
        "update-service" {
          Write-Verbose "Update command specified"
          return [int](Update-Neo4jServer -Neo4jServer $thisServer -ErrorAction Stop)
        }
        default {
          if ($Command -ne '') { Write-Host "Unknown command $Command" }
          Write-Host $HelpText
          return 1
        }
      }
      # Should not get here!
      return 2
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
