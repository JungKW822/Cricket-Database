# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.



<#
.SYNOPSIS
TODO UPDATE HELPTEXT
Retrieves properties about a Neo4j installation

.DESCRIPTION
Retrieves properties about a Neo4j installation

.PARAMETER Neo4jServer
An object representing a valid Neo4j Server object

.PARAMETER ConfigurationFile
The name of the configuration file or files to parse.  If not specified the default set of all configuration files are used.  Do not use the full path, just the filename, the path is relative to '[Neo4jHome]\conf'

.PARAMETER Name
The name of the property to retrieve.  If not specified, all properties are returned.

.EXAMPLE
Get-Neo4jSetting -Neo4jServer $ServerObject | Format-Table

Retrieves all settings for the Neo4j installation at $ServerObject

.EXAMPLE
Get-Neo4jSetting -Neo4jServer $ServerObject -Name 'dbms.active_database'

Retrieves all settings with the name 'dbms.active_database' from the Neo4j installation at $ServerObject

.EXAMPLE
Get-Neo4jSetting -Neo4jServer $ServerObject -Name 'dbms.active_database' -ConfigurationFile 'neo4j.conf'

Retrieves all settings with the name 'dbms.active_database' from the Neo4j installation at $ServerObject in 'neo4j.conf'

.OUTPUTS
System.Management.Automation.PSCustomObject
This is a Neo4j Setting Object
Properties;
'Name' : Name of the property
'Value' : Value of the property.  Multivalue properties are string arrays (string[])
'ConfigurationFile' : Name of the configuration file where the setting is defined
'IsDefault' : Whether this setting is a default value (Reserved for future use)
'Neo4jHome' : Path to the Neo4j installation

.LINK
Get-Neo4jServer 

.NOTES
This function is private to the powershell module

#>
function Get-Neo4jSetting
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [pscustomobject]$Neo4jServer

    ,[Parameter(Mandatory = $false)]
    [string[]]$ConfigurationFile = $null

    ,[Parameter(Mandatory = $false)]
    [string]$Name = ''
  )

  begin
  {
  }

  process
  {
    # Get the Neo4j Server information
    if ($Neo4jServer -eq $null) { return }

    # Set the default list of configuration files    
    if ($ConfigurationFile -eq $null)
    {
      $ConfigurationFile = ('neo4j.conf','neo4j-wrapper.conf')
    }

    $ConfigurationFile | ForEach-Object -Process `
       {
      $filename = $_
      $filePath = Join-Path -Path $Neo4jServer.ConfDir -ChildPath $filename
      if (Test-Path -Path $filePath)
      {
        $keyPairsFromFile = Get-KeyValuePairsFromConfFile -FileName $filePath
      }
      else
      {
        $keyPairsFromFile = $null
      }

      if ($keyPairsFromFile -ne $null)
      {
        $keyPairsFromFile.GetEnumerator() | Where-Object { ($Name -eq '') -or ($_.Name -eq $Name) } | ForEach-Object -Process `
           {
          $properties = @{
            'Name' = $_.Name;
            'Value' = $_.value;
            'ConfigurationFile' = $filename;
            'IsDefault' = $false;
            'Neo4jHome' = $Neo4jServer.Home;
          }

          Write-Output (New-Object -TypeName PSCustomObject -Property $properties)
        }
      }
    }
  }

  end
  {
  }
}
