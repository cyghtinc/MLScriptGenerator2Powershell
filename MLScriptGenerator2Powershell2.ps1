# Dynamic PowerShell Script Generator
# Creates truly unique PowerShell scripts with varying architecture and complexity

param (
    [int]$ScriptCount = 100,
    [string]$OutputDirectory = ".\GeneratedScripts"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Dynamic building blocks
$cmdletGroups = @{
    FileSystem = @('Get-ChildItem', 'Get-Content', 'Set-Content', 'Copy-Item', 'Move-Item', 'Remove-Item', 'Test-Path')
    Network = @('Test-Connection', 'Invoke-WebRequest', 'Test-NetConnection', 'Get-NetAdapter', 'Get-NetIPAddress')
    Process = @('Get-Process', 'Stop-Process', 'Start-Process', 'Wait-Process', 'Debug-Process')
    Service = @('Get-Service', 'Start-Service', 'Stop-Service', 'Restart-Service', 'Set-Service')
    Security = @('Get-Acl', 'Set-Acl', 'Get-AuthenticodeSignature', 'Get-CmsMessage', 'Protect-CmsMessage')
    Registry = @('Get-ItemProperty', 'Set-ItemProperty', 'Remove-ItemProperty', 'Get-ChildItem')
}

$parameterTypes = @(
    '[string]', '[int]', '[bool]', '[datetime]', '[array]', '[hashtable]', '[PSCredential]',
    '[System.Uri]', '[System.Guid]', '[System.TimeSpan]', '[System.IO.FileInfo]'
)

$validationAttributes = @(
    '[ValidateNotNullOrEmpty()]',
    '[ValidateRange(0, 100)]',
    '[ValidatePattern("^\w+$")]',
    '[ValidateScript({Test-Path $_})]',
    '[ValidateSet("Low", "Medium", "High")]'
)

function New-RandomClassName {
    $prefixes = @('Base', 'Custom', 'Advanced', 'Dynamic', 'Automated', 'Smart', 'Managed')
    $suffixes = @('Handler', 'Processor', 'Manager', 'Controller', 'Service', 'Worker', 'Agent')
    
    "$($prefixes | Get-Random)$($suffixes | Get-Random)"
}

function New-RandomFunctionName {
    $verbs = (Get-Verb).Verb
    $nouns = @('Data', 'File', 'Process', 'Service', 'Configuration', 'Resource', 'Connection', 'Task')
    
    "$($verbs | Get-Random)-$($nouns | Get-Random)"
}

function New-RandomParameter {
    $type = $parameterTypes | Get-Random
    $name = "$(Get-Random -InputObject @('Input', 'Target', 'Source', 'Data', 'Config', 'Path'))$(Get-Random -Minimum 1 -Maximum 100)"
    $validation = if ((Get-Random -Minimum 0 -Maximum 2)) { $validationAttributes | Get-Random } else { '' }
    
    "$validation`n    $type```$$name"
}

function New-RandomClass {
    $className = New-RandomClassName
    $propertyCount = Get-Random -Minimum 2 -Maximum 6
    $methodCount = Get-Random -Minimum 1 -Maximum 4

    $properties = 1..$propertyCount | ForEach-Object {
        "    $($parameterTypes | Get-Random)```$Property$_"
    }

    $methods = 1..$methodCount | ForEach-Object {
        $methodName = New-RandomFunctionName
        @"
    [$className] $methodName() {
        `$this.Property1 = 'Modified'
        return `$this
    }
"@
    }

    @"
class $className {
$($properties -join "`n")

    $className() {
        `$this.Property1 = 'Default'
    }

$($methods -join "`n`n")
}
"@
}

function New-RandomFunction {
    $functionName = New-RandomFunctionName
    $paramCount = Get-Random -Minimum 1 -Maximum 5
    $params = 1..$paramCount | ForEach-Object { New-RandomParameter }
    
    $cmdletGroup = Get-Random -InputObject $cmdletGroups.Keys
    $cmdlets = $cmdletGroups[$cmdletGroup]
    
    $operations = 1..(Get-Random -Minimum 2 -Maximum 6) | ForEach-Object {
        "    $($cmdlets | Get-Random) -Path `$Path"
    }

    @"
function $functionName {
    [CmdletBinding()]
    param(
$($params -join ",`n")
    )

    begin {
        Write-Verbose "Starting $functionName"
    }

    process {
        try {
$($operations -join "`n")
        }
        catch {
            Write-Error `$_
        }
    }

    end {
        Write-Verbose "Completed $functionName"
    }
}
"@
}

function New-ScriptContent {
    $components = @()
    
    # Add using statements
    if ((Get-Random -Minimum 0 -Maximum 2)) {
        $components += @"
using namespace System.Management.Automation
using namespace System.Collections.Generic
"@
    }

    # Add random class
    if ((Get-Random -Minimum 0 -Maximum 2)) {
        $components += New-RandomClass
    }

    # Add random number of functions
    $functionCount = Get-Random -Minimum 1 -Maximum 5
    1..$functionCount | ForEach-Object {
        $components += New-RandomFunction
    }

    # Add main script logic
    $mainLogic = @"
# Main script logic
`$data = Get-ChildItem
$($cmdletGroups[(Get-Random -InputObject $cmdletGroups.Keys)] | Get-Random) -Path .
"@
    $components += $mainLogic

    $components -join "`n`n"
}

# Generate unique scripts
1..$ScriptCount | ForEach-Object {
    $scriptContent = New-ScriptContent
    $scriptType = Get-Random -InputObject @('Utility', 'Monitor', 'Manager', 'Handler', 'Processor')
    $filename = "Script_{0:D3}_{1}.ps1" -f $_, $scriptType
    $fullPath = Join-Path $OutputDirectory $filename
    
    $scriptContent | Out-File -FilePath $fullPath -Encoding UTF8
    Write-Host "Generated script: $filename"
}

Write-Host "Script generation complete. $ScriptCount scripts created in $OutputDirectory"