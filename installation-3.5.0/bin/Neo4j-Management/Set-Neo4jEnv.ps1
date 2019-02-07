# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Sets a process-level environment variable value

.DESCRIPTION
Sets a process-level environment variable value.  This is a helper function which aids testing and mocking

.PARAMETER Name
Name of the environment variable

.PARAMETER Value
Value of the environment variable

.EXAMPLE
Set-Neo4jEnv 'Neo4jHome' 'C:\neo4j'

Sets the Neo4jHome environment variable to C:\neo4j

.OUTPUTS
System.String
Value of the environment variable

.NOTES
This function is private to the powershell module

#>
function Set-Neo4jEnv
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $false,Position = 0)]
    [string]$Name

    ,[Parameter(Mandatory = $true,ValueFromPipeline = $false,Position = 1)]
    [string]$Value
  )

  begin
  {
  }

  process {
    Set-Item -Path Env:$Name -Value $Value
  }

  end
  {
  }
}
