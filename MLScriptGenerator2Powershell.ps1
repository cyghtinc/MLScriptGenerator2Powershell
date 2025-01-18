# Comprehensive PowerShell Script Generator
# Creates diverse PowerShell scripts for research and exploration

param (
    [int]$ScriptCount = 100,
    [string]$OutputDirectory = ".\GeneratedScripts"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Expanded Script Templates
$scriptTemplates = @(
    # Previous templates...
    @{
        Name = "CSV-Data-Processor"
        Content = @'
# CSV Data Processing and Transformation Script
param(
    [string]$InputFile = "input.csv",
    [string]$OutputFile = "processed.csv"
)

function Process-CSVData {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    # Read input CSV
    $data = Import-Csv $SourcePath

    # Example transformations
    $processedData = $data | ForEach-Object {
        $row = $_
        
        # Add a computed column
        $row | Add-Member -MemberType NoteProperty -Name "ComputedValue" -Value (
            [math]::Round(
                (
                    ($row.NumericColumn1 -as [double]) * 
                    ($row.NumericColumn2 -as [double])
                ), 2
            )
        )

        # Normalize or clean specific columns
        if ($row.StringColumn) {
            $row.StringColumn = $row.StringColumn.Trim().ToLower()
        }

        $row
    }

    # Export processed data
    $processedData | Export-Csv $DestinationPath -NoTypeInformation
}

Process-CSVData -SourcePath $InputFile -DestinationPath $OutputFile
'@
    },
    @{
        Name = "Bulk-File-Renamer"
        Content = @'
# Bulk File Renaming Utility
param(
    [string]$SourceDirectory = "C:\WorkFolder",
    [string]$Pattern = "*.txt",
    [string]$RenameFormat = "file_{0:D4}{1}"
)

function Rename-BulkFiles {
    param(
        [string]$Path,
        [string]$FilePattern,
        [string]$NameFormat
    )

    # Get files matching the pattern
    $files = Get-ChildItem -Path $Path -Filter $FilePattern

    # Track rename operations
    $renameLog = @()

    # Rename files
    $counter = 1
    foreach ($file in $files) {
        $newFileName = $NameFormat -f $counter, $file.Extension
        $newFullPath = Join-Path $Path $newFileName

        # Rename operation
        try {
            Rename-Item -Path $file.FullName -NewName $newFileName -ErrorAction Stop
            $renameLog += [PSCustomObject]@{
                OriginalName = $file.Name
                NewName = $newFileName
                Status = "Success"
            }
        }
        catch {
            $renameLog += [PSCustomObject]@{
                OriginalName = $file.Name
                NewName = $newFileName
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }

        $counter++
    }

    # Export rename log
    $renameLog | Export-Csv "rename_log.csv" -NoTypeInformation
}

Rename-BulkFiles -Path $SourceDirectory -FilePattern $Pattern -NameFormat $RenameFormat
'@
    },
    @{
        Name = "Environment-Config-Checker"
        Content = @'
# Environment Configuration Checker
function Test-EnvironmentConfiguration {
    # Check system environment variables
    $environmentCheck = @{
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        SystemDrive = $env:SystemDrive
        ProgramFiles = $env:ProgramFiles
        
        # Custom variable checks
        CustomVariables = @{
            JAVA_HOME = $env:JAVA_HOME
            PYTHON_HOME = $env:PYTHON_HOME
            PATH_LENGTH = $env:PATH.Length
        }

        # Installed .NET versions
        DotNetVersions = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
            Get-ItemProperty -Name Version, Release -ErrorAction SilentlyContinue |
            Where-Object { $_.PSChildName -match '^v[0-9]' } |
            Select-Object PSChildName, Version, Release

        # Check PowerShell version
        PowerShellVersion = $PSVersionTable
    }

    # Export configuration check
    $environmentCheck | ConvertTo-Json -Depth 5 | Out-File "environment_config.json"
}

Test-EnvironmentConfiguration
'@
    },
    @{
        Name = "Random-Data-Generator"
        Content = @'
# Random Data Generation Utility
param(
    [int]$RecordCount = 1000,
    [string]$OutputFile = "random_data.csv"
)

function New-RandomDataset {
    param(
        [int]$Count,
        [string]$Destination
    )

    # Generate random dataset
    $randomData = 1..$Count | ForEach-Object {
        [PSCustomObject]@{
            ID = $_
            Name = (-join ((65..90) | Get-Random -Count (Get-Random -Minimum 3 -Maximum 10) | ForEach-Object {[char]$_}))
            Age = Get-Random -Minimum 18 -Maximum 85
            Salary = [math]::Round((Get-Random -Minimum 30000 -Maximum 150000), 2)
            City = (Get-Random -InputObject @("New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego"))
            IsEmployed = (Get-Random -Minimum 0 -Maximum 2) -eq 1
            Score = [math]::Round((Get-Random -Minimum 0 -Maximum 100), 2)
        }
    }

    # Export to CSV
    $randomData | Export-Csv $Destination -NoTypeInformation
}

New-RandomDataset -Count $RecordCount -Destination $OutputFile
'@
    },
    @{
        Name = "Log-Analysis-Tool"
        Content = @'
# Basic Log Analysis Script
param(
    [string]$LogPath = "C:\Logs\application.log",
    [int]$TopErrors = 10
)

function Analyze-LogFile {
    param(
        [string]$Path,
        [int]$ErrorLimit
    )

    # Read log file
    $logContents = Get-Content $Path

    # Analyze log entries
    $logAnalysis = @{
        TotalLogEntries = $logContents.Count
        ErrorEntries = ($logContents | Where-Object { $_ -match "ERROR|CRITICAL" })
        TopErrors = ($logContents | 
            Where-Object { $_ -match "ERROR|CRITICAL" } | 
            Group-Object | 
            Sort-Object Count -Descending | 
            Select-Object -First $ErrorLimit)
        
        TimestampRange = @{
            Earliest = ($logContents | 
                Where-Object { $_ -match "\d{4}-\d{2}-\d{2}" } | 
                Select-Object -First 1)
            Latest = ($logContents | 
                Where-Object { $_ -match "\d{4}-\d{2}-\d{2}" } | 
                Select-Object -Last 1)
        }
    }

    # Export analysis results
    $logAnalysis | ConvertTo-Json -Depth 5 | Out-File "log_analysis_report.json"
}

Analyze-LogFile -Path $LogPath -ErrorLimit $TopErrors
'@
    },
    @{
        Name = "Folder-Size-Calculator"
        Content = @'
# Recursive Folder Size Calculator
param(
    [string]$RootPath = "C:\",
    [int]$TopFolders = 10
)

function Get-FolderSizes {
    param(
        [string]$Path,
        [int]$LimitResults
    )

    # Recursive folder size calculation
    $folderSizes = Get-ChildItem -Path $Path -Directory -Recurse -ErrorAction SilentlyContinue | 
        ForEach-Object {
            $folderPath = $_.FullName
            $size = 0
            
            try {
                $size = (Get-ChildItem -Path $folderPath -Recurse -File -ErrorAction Stop | 
                    Measure-Object -Property Length -Sum).Sum
            }
            catch {
                $size = 0
            }

            [PSCustomObject]@{
                FolderPath = $folderPath
                SizeBytes = $size
                SizeMB = [math]::Round($size / 1MB, 2)
            }
        } | 
        Sort-Object SizeBytes -Descending | 
        Select-Object -First $LimitResults

    # Export results
    $folderSizes | Export-Csv "folder_sizes.csv" -NoTypeInformation
}

Get-FolderSizes -Path $RootPath -LimitResults $TopFolders
'@
    },
    @{
        Name = "Web-Resource-Checker"
        Content = @'
# Web Resource Availability Checker
param(
    [string[]]$URLs = @(
        "https://www.google.com", 
        "https://www.microsoft.com", 
        "https://www.github.com"
    )
)

function Test-WebResourceAvailability {
    param(
        [string[]]$WebsiteList
    )

    # Check website availability
    $availabilityReport = $WebsiteList | ForEach-Object {
        $url = $_
        $result = $null

        try {
            $request = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10 -ErrorAction Stop
            $result = [PSCustomObject]@{
                URL = $url
                Status = $request.StatusCode
                StatusDescription = $request.StatusDescription
                ResponseTime = $request.Headers.'x-response-time'
                TimeStamp = Get-Date
            }
        }
        catch {
            $result = [PSCustomObject]@{
                URL = $url
                Status = "Failed"
                ErrorMessage = $_.Exception.Message
                TimeStamp = Get-Date
            }
        }

        $result
    }

    # Export availability report
    $availabilityReport | ConvertTo-Json -Depth 5 | Out-File "web_availability_report.json"
}

Test-WebResourceAvailability -WebsiteList $URLs
'@
    },
    @{
        Name = "System-Compliance-Check"
        Content = @'
# System Compliance and Security Check
function Test-SystemCompliance {
    # Comprehensive system compliance checks
    $complianceCheck = @{
        Timestamp = Get-Date
        
        # Windows Update Status
        WindowsUpdateStatus = (Get-Service -Name wuauserv).Status
        
        # Firewall Status
        FirewallProfile = Get-NetFirewallProfile | Select-Object Name, Enabled
        
        # Antivirus Status
        AntivirusStatus = Get-MpComputerStatus | Select-Object 
            ComputerStatus, 
            RealTimeProtectionEnabled, 
            LastFullScanTime,
            LastQuickScanTime
        
        # User Account Control Settings
        UACSettings = @{
            Level = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').EnableLUA
            Prompt = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').PromptOnSecureDesktop
        }
        
        # Installed Security Updates
        RecentSecurityUpdates = Get-HotFix | 
            Where-Object { $_.Description -match "Security Update" } | 
            Select-Object -Last 10
    }

    # Export compliance report
    $complianceCheck | ConvertTo-Json -Depth 5 | Out-File "system_compliance_report.json"
}

Test-SystemCompliance
'@
    },
    @{
        Name = "Remote-Ping-Monitor"
        Content = @'
# Remote Host Ping Monitoring Script
param(
    [string[]]$Targets = @("8.8.8.8", "1.1.1.1", "9.9.9.9"),
    [int]$IntervalSeconds = 60,
    [int]$DurationMinutes = 5
)

function Start-PingMonitoring {
    param(
        [string[]]$HostList,
        [int]$Interval,
        [int]$Duration
    )

    $endTime = (Get-Date).AddMinutes($Duration)
    $pingResults = @()

    while ((Get-Date) -lt $endTime) {
        $currentPings = $HostList | ForEach-Object {
            $target = $_
            $pingResult = Test-Connection -ComputerName $target -Count 4 -Quiet
            
            [PSCustomObject]@{
                Target = $target
                Status = $pingResult
                Timestamp = Get-Date
                ResponseTime = (Test-Connection -ComputerName $target -Count 1).ResponseTime
            }
        }

        $pingResults += $currentPings
        Start-Sleep -Seconds $Interval
    }

    # Export ping monitoring results
    $pingResults | Export-Csv "ping_monitor_log.csv" -NoTypeInformation
}

Start-PingMonitoring -HostList $Targets -Interval $IntervalSeconds -Duration $DurationMinutes
'@
    }
)

# Function to generate unique filenames (Same as previous script)
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