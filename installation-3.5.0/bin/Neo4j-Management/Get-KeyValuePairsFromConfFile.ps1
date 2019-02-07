# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Parses a Neo4j configuration file into a hashtable

.DESCRIPTION
Parses a Neo4j configuration file into a hashtable.  Multivalue keys are output as string[] types.

.PARAMETER Filename
The full path to the file to read

.EXAMPLE
Get-KeyValuePairsFromConfFile -Filename 'C:\Neo4j\conf\neo4j.conf'

Reads the file 'C:\Neo4j\conf\neo4j.conf' and outputs a hashtable of key/value pairs

.OUTPUTS
System.Collections.Hashtable

.NOTES
This function is private to the powershell module

#>
function Get-KeyValuePairsFromConfFile
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $false,ValueFromPipeline = $false)]
    [string]$Filename = ''
  )

  process
  {
    if ($filename -eq '') { throw "Filename must be specified"; return }
    $properties = @{}
    Get-Content -Path $filename -Filter $Filter | ForEach-Object -Process `
       {
      $line = $_
      $misc = $line.IndexOf('#')
      if ($misc -ge 0) { $line = $line.SubString(0,$misc) }

      if ($matches -ne $null) { $matches.Clear() }
      if ($line -match '^([^=]+)=(.+)$')
      {
        $keyName = $matches[1].Trim()
        if ($properties.Contains($keyName))
        {
          # There is already a property with this name so it must be a collection of properties.  Turn the value into an array and add it
          if ($properties[$keyName] -is [string]) { $properties[$keyName] = [string[]]@($properties[$keyName]) }
          $properties[$keyName] = $properties[$keyName] + $matches[2].Trim()
        }
        else
        {
          $properties[$keyName] = $matches[2].Trim()
        }
      }
    }
    Write-Output $properties
  }
}
