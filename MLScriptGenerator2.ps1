# Safe PowerShell Script Research Generator
# Creates diverse, educational PowerShell scripts for research

param (
    [int]$ScriptCount = 100,
    [string]$OutputDirectory = ".\ResearchScripts"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Diverse Script Templates
$scriptTemplates = @(
    @{
        Name = "System-Info-Collector"
        Content = @'
# Collect and log system information
$systemInfo = @{
    Hostname = $env:COMPUTERNAME
    OSVersion = (Get-WmiObject Win32_OperatingSystem).Caption
    Processor = (Get-WmiObject Win32_Processor).Name
    TotalMemory = "{0:N2} GB" -f ((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    Date = Get-Date
}

$systemInfo | ConvertTo-Json | Out-File "system_info_log.txt"
'@
    },
    @{
        Name = "Network-Diagnostic"
        Content = @'
# Basic network diagnostic script
function Test-NetworkConnectivity {
    param(
        [string[]]$Targets = @("google.com", "microsoft.com", "github.com")
    )

    $results = @{}
    foreach ($target in $Targets) {
        $ping = Test-Connection -ComputerName $target -Count 4 -Quiet
        $results[$target] = @{
            Reachable = $ping
            Timestamp = Get-Date
        }
    }

    $results | ConvertTo-Json | Out-File "network_diagnostic_log.json"
}

Test-NetworkConnectivity
'@
    },
    @{
        Name = "File-Organizer"
        Content = @'
# Organize files in a specified directory
param(
    [string]$SourcePath = "C:\Downloads"
)

function Organize-Files {
    $extensions = @{
        "Documents" = @(".pdf", ".docx", ".txt")
        "Images" = @(".jpg", ".png", ".gif")
        "Spreadsheets" = @(".xlsx", ".csv")
        "Compressed" = @(".zip", ".rar", ".7z")
    }

    Get-ChildItem $SourcePath | ForEach-Object {
        $file = $_
        foreach ($category in $extensions.Keys) {
            $targetFolder = Join-Path $SourcePath $category
            if (-not (Test-Path $targetFolder)) {
                New-Item -Path $targetFolder -ItemType Directory | Out-Null
            }

            if ($extensions[$category] -contains $file.Extension) {
                Move-Item -Path $file.FullName -Destination $targetFolder -ErrorAction SilentlyContinue
            }
        }
    }
}

Organize-Files
'@
    },
    @{
        Name = "Performance-Monitor"
        Content = @'
# Monitor system performance
function Get-PerformanceSnapshot {
    $cpu = (Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average).Average
    $memory = Get-WmiObject Win32_OperatingSystem
    $memoryUsage = [math]::Round(((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100), 2)
    $diskIO = Get-Counter "\PhysicalDisk(_Total)\Disk Transfers/sec"

    $performanceLog = @{
        Timestamp = Get-Date
        CPUUsage = $cpu
        MemoryUsagePercent = $memoryUsage
        DiskTransfersPerSecond = $diskIO.CounterSamples.CookedValue
    }

    $performanceLog | ConvertTo-Json | Out-File "performance_log.json"
}

Get-PerformanceSnapshot
'@
    },
    @{
        Name = "Software-Inventory"
        Content = @'
# Collect installed software inventory
function Get-SoftwareInventory {
    $software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Select-Object DisplayName, Publisher, InstallDate, Version |
        Where-Object { $_.DisplayName } |
        Sort-Object DisplayName

    $softwareInventory = @{
        Timestamp = Get-Date
        TotalApplications = $software.Count
        Applications = $software
    }

    $softwareInventory | ConvertTo-Json -Depth 5 | Out-File "software_inventory.json"
}

Get-SoftwareInventory
'@
    },
    @{
        Name = "Scheduled-Task-Audit"
        Content = @'
# Audit scheduled tasks
function Get-ScheduledTaskAudit {
    $tasks = Get-ScheduledTask | ForEach-Object {
        @{
            TaskName = $_.TaskName
            Path = $_.TaskPath
            State = $_.State
            LastRunTime = $_.LastRunTime
            NextRunTime = $_.NextRunTime
        }
    }

    $taskAudit = @{
        Timestamp = Get-Date
        TotalTasks = $tasks.Count
        Tasks = $tasks
    }

    $taskAudit | ConvertTo-Json -Depth 5 | Out-File "scheduled_tasks_audit.json"
}

Get-ScheduledTaskAudit
'@
    },
    @{
        Name = "Process-Monitor"
        Content = @'
# Monitor running processes
function Get-ProcessSnapshot {
    $processes = Get-Process | Select-Object Name, Id, CPU, Memory, StartTime |
        Sort-Object -Property CPU -Descending

    $processLog = @{
        Timestamp = Get-Date
        TotalProcesses = $processes.Count
        TopProcesses = $processes | Select-Object -First 10
    }

    $processLog | ConvertTo-Json -Depth 5 | Out-File "process_snapshot.json"
}

Get-ProcessSnapshot
'@
    }
)

# Function to generate unique filenames
function Get-UniqueFileName {
    param(
        [string]$Directory,
        [string]$BaseName
    )
    
    $counter = 1
    $filename = "$BaseName.ps1"
    $fullPath = Join-Path $Directory $filename
    
    while (Test-Path $fullPath) {
        $filename = "$BaseName_$counter.ps1"
        $fullPath = Join-Path $Directory $filename
        $counter++
    }
    
    return $filename
}

# Generate scripts
for ($i = 1; $i -le $ScriptCount; $i++) {
    # Randomly select a template
    $template = $scriptTemplates | Get-Random
    
    # Generate unique filename
    $filename = Get-UniqueFileName -Directory $OutputDirectory -BaseName $template.Name
    
    # Create full path
    $fullPath = Join-Path $OutputDirectory $filename
    
    # Write script content
    $template.Content | Out-File -FilePath $fullPath -Encoding UTF8
    
    Write-Host "Generated script: $filename"
}

Write-Host "Script generation complete. $ScriptCount scripts created in $OutputDirectory"