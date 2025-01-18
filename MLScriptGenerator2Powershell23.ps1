# Enhanced PowerShell Script Generator
# Creates highly diverse scripts with significantly varying sizes

param (
    [int]$ScriptCount = 100,
    [string]$OutputDirectory = ".\GeneratedScripts",
    [switch]$IncludeComments = $true
)

# Create output directory if needed
if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Content generation helpers
function Get-RandomFunctionName {
    $verbs = Get-Verb | Select-Object -ExpandProperty Verb
    $nouns = @(
        'Data', 'File', 'Process', 'Service', 'Config', 'Log', 'Event',
        'Cache', 'Queue', 'Stack', 'Tree', 'Network', 'Memory', 'Disk',
        'Registry', 'Performance', 'Security', 'Resource', 'Policy',
        'Certificate', 'Credential', 'Permission', 'Audit', 'Report'
    )
    "$($verbs | Get-Random)-$($nouns | Get-Random)$((Get-Random -Minimum 1 -Maximum 999).ToString('000'))"
}

function Get-RandomClassName {
    $prefixes = @('Advanced', 'Custom', 'Enhanced', 'Dynamic', 'Managed', 'Secure', 'High', 'Multi')
    $types = @('Handler', 'Processor', 'Manager', 'Controller', 'Service', 'Provider', 'Factory', 'Builder')
    $domains = @('Data', 'File', 'Process', 'Network', 'Security', 'Resource', 'Config', 'Log')
    
    "$($prefixes | Get-Random)$($domains | Get-Random)$($types | Get-Random)"
}

function Get-RandomVariable {
    $prefixes = @('temp', 'obj', 'data', 'config', 'result', 'cache', 'buffer', 'params')
    $types = @('Item', 'List', 'Collection', 'Set', 'Array', 'Map', 'Queue', 'Stack')
    "$($prefixes | Get-Random)$($types | Get-Random)$((Get-Random -Minimum 1 -Maximum 999).ToString('000'))"
}

function Get-LargeCommentBlock {
    $commentTypes = @(
        {
            $methodCount = Get-Random -Minimum 10 -Maximum 50
            $methods = 1..$methodCount | ForEach-Object {
                "    - Method$_() : Handles specific processing logic for component $_"
            }
            @"
<#
.SYNOPSIS
    Advanced processing framework for enterprise data management.
.DESCRIPTION
    Provides a comprehensive framework for managing and processing enterprise data
    with support for various data sources, transformation pipelines, and output formats.
.NOTES
    Module: Enterprise Data Processing
    Version: $((Get-Random -Minimum 1 -Maximum 10)).$((Get-Random -Minimum 0 -Maximum 100))
    Author: Generated Code
    Generated: $(Get-Date)
.COMPONENT
    The module consists of the following major components:
$($methods -join "`n")
#>
"@
        },
        {
            $steps = 1..(Get-Random -Minimum 15 -Maximum 40) | ForEach-Object {
                "    Step $_. Perform specific validation and transformation on input data"
            }
            @"
<#
Comprehensive Data Processing Pipeline
====================================

This script implements a complex data processing pipeline with multiple stages
and extensive error handling. The process follows these steps:

$($steps -join "`n")

Performance Considerations:
-------------------------
- Memory usage is optimized for large datasets
- Implements parallel processing where applicable
- Uses buffered I/O for file operations
- Implements caching for frequently accessed data

Security Measures:
-----------------
- All data is validated before processing
- Implements proper error handling and logging
- Sensitive data is properly encrypted
- Access control is strictly enforced
#>
"@
        }
    )
    
    & (Get-Random -InputObject $commentTypes)
}

function Get-ComplexFunction {
    $functionName = Get-RandomFunctionName
    $paramCount = Get-Random -Minimum 5 -Maximum 15
    $params = 1..$paramCount | ForEach-Object {
        $paramName = "Param$_"
        $paramType = Get-Random -InputObject @(
            '[string]', '[int]', '[bool]', '[DateTime]', '[array]', '[hashtable]',
            '[PSCredential]', '[System.Uri]', '[System.Guid]', '[System.TimeSpan]',
            '[System.IO.FileInfo]', '[System.Security.SecureString]'
        )
        "        [Parameter(Mandatory=`$$([bool]$(Get-Random -Minimum 0 -Maximum 2))))`n        $paramType```$$paramName"
    }
    
    @"
function $functionName {
    [CmdletBinding()]
    param(
$($params -join ",`n`n")
    )
    
    begin {
        `$startTime = Get-Date
        Write-Verbose "Starting $functionName at `$startTime"
        
        # Initialize processing environment
        `$processingEnvironment = @{
            StartTime = `$startTime
            ComputerName = `$env:COMPUTERNAME
            UserName = `$env:USERNAME
            ProcessID = `$PID
        }
        
        # Set up logging
        `$logFile = Join-Path `$env:TEMP "$functionName.log"
        if (-not (Test-Path `$logFile)) {
            New-Item -Path `$logFile -ItemType File -Force | Out-Null
        }
    }
    
    process {
        try {
            # Main processing logic
            `$results = foreach (`$item in `$inputData) {
                try {
                    `$processedItem = `$item | ForEach-Object {
                        # Transformation logic
                        `$_ | Add-Member -MemberType NoteProperty -Name "ProcessedBy" -Value `$env:USERNAME -PassThru
                        `$_ | Add-Member -MemberType NoteProperty -Name "ProcessedOn" -Value (Get-Date) -PassThru
                    }
                    
                    Write-Verbose "Processed item: `$(`$processedItem.ID)"
                    `$processedItem
                }
                catch {
                    Write-Warning "Error processing item: `$_"
                    continue
                }
            }
            
            # Additional processing steps
            `$results | Group-Object ProcessedBy | ForEach-Object {
                [PSCustomObject]@{
                    Processor = `$_.Name
                    Count = `$_.Count
                    Items = `$_.Group
                }
            }
        }
        catch {
            Write-Error "Critical error in $functionName : `$_"
            throw
        }
    }
    
    end {
        `$endTime = Get-Date
        `$duration = `$endTime - `$startTime
        
        # Generate execution summary
        `$summary = [PSCustomObject]@{
            FunctionName = '$functionName'
            StartTime = `$startTime
            EndTime = `$endTime
            Duration = `$duration
            ItemsProcessed = (`$results | Measure-Object).Count
        }
        
        # Log completion
        Add-Content -Path `$logFile -Value "Completed at `$endTime. Duration: `$(`$duration.TotalSeconds) seconds"
        
        Write-Verbose "Completed $functionName. Duration: `$(`$duration.TotalSeconds) seconds"
        return `$summary
    }
}
"@
}

function Get-ComplexClass {
    $className = Get-RandomClassName
    $propertyCount = Get-Random -Minimum 10 -Maximum 30
    $methodCount = Get-Random -Minimum 5 -Maximum 20
    
    $properties = 1..$propertyCount | ForEach-Object {
        $propType = Get-Random -InputObject @(
            '[string]', '[int]', '[bool]', '[DateTime]', '[array]', '[hashtable]',
            '[PSCustomObject]', '[System.Uri]', '[System.Guid]', '[System.TimeSpan]'
        )
        "    $propType```$Property$_"
    }
    
    $methods = 1..$methodCount | ForEach-Object {
        $methodName = "Method$_"
        $paramCount = Get-Random -Minimum 1 -Maximum 5
        $params = 1..$paramCount | ForEach-Object {
            "        [string]```$param$_"
        }
        
        @"
    [$className] $methodName(
$($params -join ",`n")
    ) {
        try {
            # Method implementation
            `$result = foreach (`$p in `$param1) {
                [PSCustomObject]@{
                    Input = `$p
                    Processed = `$this.ProcessData(`$p)
                    Timestamp = Get-Date
                }
            }
            `$this.Property1 = `$result
            return `$this
        }
        catch {
            throw "Error in : `$_"
        }
    }
"@
    }
    
    @"
class $className {
$($properties -join "`n")

    $className() {
        `$this.Property1 = 'Default'
        `$this.Initialize()
    }
    
    hidden [void]Initialize() {
        # Complex initialization logic
        `$this.Property2 = Get-Date
        `$this.Property3 = [System.Guid]::NewGuid()
        `$this.Property4 = @{
            StartTime = Get-Date
            ProcessID = `$PID
            ComputerName = `$env:COMPUTERNAME
        }
    }
    
$($methods -join "`n`n")
}
"@
}

function New-ScriptContent {
    param (
        [string]$Size
    )
    
    $content = [System.Collections.ArrayList]@()
    
    # Add initial comments and using statements
    $content.Add($(Get-LargeCommentBlock)) | Out-Null
    $content.Add(@"
using namespace System.Management.Automation
using namespace System.Collections.Generic
using namespace System.Text.RegularExpressions
using namespace System.Security.Cryptography
using namespace System.Net.NetworkInformation
"@) | Out-Null
    
    switch ($Size) {
        'Small' {
            # 1-2 functions
            1..2 | ForEach-Object {
                $content.Add($(Get-ComplexFunction)) | Out-Null
            }
        }
        'Medium' {
            # 3-5 functions and 1-2 classes
            1..2 | ForEach-Object {
                $content.Add($(Get-ComplexClass)) | Out-Null
            }
            1..5 | ForEach-Object {
                $content.Add($(Get-ComplexFunction)) | Out-Null
            }
        }
        'Large' {
            # 5-10 functions and 2-4 classes
            1..4 | ForEach-Object {
                $content.Add($(Get-ComplexClass)) | Out-Null
            }
            1..10 | ForEach-Object {
                $content.Add($(Get-ComplexFunction)) | Out-Null
            }
        }
        'VeryLarge' {
            # 10-20 functions and 4-8 classes
            1..8 | ForEach-Object {
                $content.Add($(Get-ComplexClass)) | Out-Null
            }
            1..20 | ForEach-Object {
                $content.Add($(Get-ComplexFunction)) | Out-Null
            }
        }
    }
    
    $content -join "`n`n"
}

# Generate scripts with varying sizes
# Generate scripts with varying sizes
1..$ScriptCount | ForEach-Object {
    # Determine script size based on probability - ensure single string value
    $rand = Get-Random -Minimum 1 -Maximum 1000
    $size = if ($rand -le 400) { 
        'Small' 
    } elseif ($rand -le 700) { 
        'Medium'
    } elseif ($rand -le 900) { 
        'Large'
    } else { 
        'VeryLarge'
    }

    Write-Verbose "Generating $size script..."

    # Generate content
    $content = New-ScriptContent -Size $size

    # Create filename - ensure single string value
    $filename = "Script_{0:D3}_{1}.ps1" -f $_, $size
    $fullPath = Join-Path $OutputDirectory $filename
    
    # Write content
    $content | Out-File -FilePath $fullPath -Encoding UTF8 -Force
    
    # Get and display file size
    $fileSize = (Get-Item $fullPath).Length / 1KB
    Write-Host "Generated $size script: $filename (Size: $($fileSize.ToString('N2')) KB)"
}

Write-Host "`nScript generation complete. $ScriptCount scripts created in $OutputDirectory"