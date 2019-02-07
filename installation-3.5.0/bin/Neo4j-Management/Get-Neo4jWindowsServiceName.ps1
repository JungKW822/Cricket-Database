# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Retrieves the name of the Windows Service from the configuration information

.DESCRIPTION
Retrieves the name of the Windows Service from the configuration information

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server object

.EXAMPLE
Get-Neo4jWindowsServiceName -Neo4jServer $ServerObject

Retrieves the name of the Windows Service for the Neo4j Database at $ServerObject

.OUTPUTS
System.String
The name of the Windows Service or $null if it could not be determined

.NOTES
This function is private to the powershell module

#>
function Get-Neo4jWindowsServiceName
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
    $ServiceName = ''
    # Try neo4j.conf first, but then fallback to neo4j-wrapper.conf for backwards compatibility reasons
    $setting = (Get-Neo4jSetting -ConfigurationFile 'neo4j.conf' -Name 'dbms.windows_service_name' -Neo4jServer $Neo4jServer)
    if ($setting -ne $null) {
      $ServiceName = $setting.value
    } else {
      $setting = (Get-Neo4jSetting -ConfigurationFile 'neo4j-wrapper.conf' -Name 'dbms.windows_service_name' -Neo4jServer $Neo4jServer)
      if ($setting -ne $null) { $ServiceName = $setting.value }
    }

    if ($ServiceName -eq '')
    {
      throw 'Could not find the Windows Service Name for Neo4j (dbms.windows_service_name in neo4j.conf)'
      return $null
    }
    else
    {
      Write-Verbose "Neo4j Windows Service Name is $ServiceName"
      Write-Output $ServiceName.Trim()
    }
  }

  end
  {
  }
}
