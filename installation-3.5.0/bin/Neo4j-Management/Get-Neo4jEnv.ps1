# Copyright (c) 2002-2018 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
# This file is a commercial add-on to Neo4j Enterprise Edition.


<#
.SYNOPSIS
Retrieves an environment variable value

.DESCRIPTION
Retrieves an environment variable value.  This is a helper function which aids testing and mocking

.PARAMETER Name
Name of the environment vairable

.EXAMPLE
Get-Neo4jEnv 'Neo4jHome'

Retrieves the Neo4jHome environment variable

.OUTPUTS
System.String
Value of the environment variable

Null
Variable doesn't exist

.NOTES
This function is private to the powershell module

#>
function Get-Neo4jEnv
{
  [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $false,Position = 0)]
    [string]$Name
  )

  begin
  {
  }

  process {
    Get-ChildItem -Path Env: |
    Where-Object { $_.Name.ToUpper() -eq $Name.ToUpper() } |
    Select-Object -First 1 |
    ForEach-Object { $_.value }
  }

  end
  {
  }
}
