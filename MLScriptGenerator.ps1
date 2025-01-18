# Machine Learning PowerShell Script Generator
# Generates diverse PowerShell scripts for ML workflows

param (
    [int]$ScriptCount = 100,
    [string]$OutputDirectory = ".\MLScripts"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory | Out-Null
}

# Script Templates with Unique Purposes
$scriptTemplates = @(
    @{
        Name = "Data-Preprocessing"
        Content = @'
param(
    [string]$InputPath,
    [string]$OutputPath
)

# Data Preprocessing Script
function Preprocess-MLData {
    param(
        [string]$InputFile,
        [string]$OutputFile
    )

    # Read input data
    $data = Import-Csv $InputFile

    # Basic preprocessing steps
    $cleanedData = $data | ForEach-Object {
        # Remove null values
        $_ | Where-Object { $_.PSObject.Properties.Value -ne $null }
    }

    # Normalize numeric columns
    $numericColumns = $cleanedData[0].PSObject.Properties.Name | 
        Where-Object { $cleanedData[0].$_ -match '^\d+(\.\d+)?$' }

    foreach ($col in $numericColumns) {
        $max = ($cleanedData | Measure-Object -Property $col -Maximum).Maximum
        $min = ($cleanedData | Measure-Object -Property $col -Minimum).Minimum
        
        $cleanedData | ForEach-Object {
            $_.$col = [math]::Round(($_.$col - $min) / ($max - $min), 4)
        }
    }

    # Export cleaned data
    $cleanedData | Export-Csv $OutputFile -NoTypeInformation
}

Preprocess-MLData -InputFile $InputPath -OutputFile $OutputPath
'@
    },
    @{
        Name = "Model-Training"
        Content = @'
param(
    [string]$DataPath,
    [string]$ModelOutputPath,
    [string]$ModelType = "Linear"
)

# Machine Learning Model Training Simulator
function Train-MLModel {
    param(
        [string]$TrainingData,
        [string]$ModelPath,
        [string]$Type
    )

    # Simulated model training process
    $trainingLog = @{
        StartTime = Get-Date
        DataSource = $TrainingData
        ModelType = $Type
        Hyperparameters = @{
            LearningRate = Get-Random -Minimum 0.01 -Maximum 0.1
            Epochs = Get-Random -Minimum 50 -Maximum 200
            BatchSize = Get-Random -Minimum 16 -Maximum 128
        }
    }

    # Generate a mock model performance metric
    $trainingLog.ModelAccuracy = [math]::Round((Get-Random -Minimum 0.6 -Maximum 0.95), 4)

    # Export training log
    $trainingLog | ConvertTo-Json | Out-File "$ModelPath-training-log.json"

    # Create a dummy model file
    "Trained Model: $Type" | Out-File $ModelPath
}

Train-MLModel -TrainingData $DataPath -ModelPath $ModelOutputPath -Type $ModelType
'@
    },
    @{
        Name = "Feature-Engineering"
        Content = @'
param(
    [string]$InputDataset,
    [string]$OutputDataset,
    [int]$FeatureCount = 10
)

# Advanced Feature Engineering Script
function Create-MLFeatures {
    param(
        [string]$DataFile,
        [string]$OutputFile,
        [int]$NumFeatures
    )

    # Read input data
    $originalData = Import-Csv $DataFile

    # Dynamically generate synthetic features
    $enhancedData = $originalData | ForEach-Object {
        $row = $_
        
        # Add synthetic features
        for ($i = 1; $i -le $NumFeatures; $i++) {
            $featureName = "SyntheticFeature_$i"
            
            # Different feature generation strategies
            switch ($i % 5) {
                0 { $row | Add-Member -MemberType NoteProperty -Name $featureName -Value ([math]::Log($row.SomeNumericColumn + 1)) }
                1 { $row | Add-Member -MemberType NoteProperty -Name $featureName -Value ([math]::Pow($row.AnotherColumn, 2)) }
                2 { $row | Add-Member -MemberType NoteProperty -Name $featureName -Value (($row.SomeColumn -replace '[^a-zA-Z]').Length) }
                3 { $row | Add-Member -MemberType NoteProperty -Name $featureName -Value ([math]::Sin($row.NumericValue)) }
                4 { $row | Add-Member -MemberType NoteProperty -Name $featureName -Value (Get-Random -Minimum 0 -Maximum 1) }
            }
        }
        
        $row
    }

    # Export enhanced dataset
    $enhancedData | Export-Csv $OutputFile -NoTypeInformation
}

Create-MLFeatures -DataFile $InputDataset -OutputFile $OutputDataset -NumFeatures $FeatureCount
'@
    },
    @{
        Name = "Data-Validation"
        Content = @'
param(
    [string]$DatasetPath,
    [string]$ReportPath
)

# Machine Learning Dataset Validation Script
function Validate-MLDataset {
    param(
        [string]$InputDataset,
        [string]$ValidationReport
    )

    # Read dataset
    $data = Import-Csv $InputDataset

    # Comprehensive data validation
    $validationResults = @{
        TotalRecords = $data.Count
        MissingValues = @{}
        DataTypes = @{}
        OutlierDetection = @{}
        ReportTime = Get-Date
    }

    # Check for missing values
    $data[0].PSObject.Properties.Name | ForEach-Object {
        $column = $_
        $missingCount = ($data | Where-Object { $null -eq $_.$column }).Count
        $validationResults.MissingValues[$column] = $missingCount
    }

    # Basic data type inference
    $data[0].PSObject.Properties.Name | ForEach-Object {
        $column = $_
        $uniqueTypes = ($data | Select-Object -ExpandProperty $column | ForEach-Object { $_.GetType().Name }) | Sort-Object -Unique
        $validationResults.DataTypes[$column] = $uniqueTypes
    }

    # Simple outlier detection
    $numericColumns = $data[0].PSObject.Properties.Name | 
        Where-Object { $data[0].$_ -match '^\d+(\.\d+)?$' }

    foreach ($col in $numericColumns) {
        $values = $data | Select-Object -ExpandProperty $col
        $mean = ($values | Measure-Object -Average).Average
        $stdDev = [math]::Sqrt(
            (($values | ForEach-Object { [math]::Pow($_ - $mean, 2) } | Measure-Object -Average).Average)
        )
        
        $outliers = $values | Where-Object { [math]::Abs($_ - $mean) -gt (2 * $stdDev) }
        $validationResults.OutlierDetection[$col] = @{
            OutlierCount = $outliers.Count
            OutlierPercentage = [math]::Round(($outliers.Count / $values.Count) * 100, 2)
        }
    }

    # Export validation report
    $validationResults | ConvertTo-Json -Depth 5 | Out-File $ValidationReport
}

Validate-MLDataset -InputDataset $DatasetPath -ValidationReport $ReportPath
'@
    },
    @{
        Name = "Model-Evaluation"
        Content = @'
param(
    [string]$ModelPath,
    [string]$TestDataPath,
    [string]$ResultsPath
)

# Machine Learning Model Evaluation Script
function Evaluate-MLModel {
    param(
        [string]$TrainedModel,
        [string]$TestData,
        [string]$EvaluationResults
    )

    # Simulated model evaluation
    $evaluationMetrics = @{
        ModelSource = $TrainedModel
        TestDataset = $TestData
        Timestamp = Get-Date
        Metrics = @{
            Accuracy = [math]::Round((Get-Random -Minimum 0.6 -Maximum 0.95), 4)
            Precision = [math]::Round((Get-Random -Minimum 0.6 -Maximum 0.95), 4)
            Recall = [math]::Round((Get-Random -Minimum 0.6 -Maximum 0.95), 4)
            F1Score = [math]::Round((Get-Random -Minimum 0.6 -Maximum 0.95), 4)
        }
        Confusion = @{
            TruePositive = (Get-Random -Minimum 100 -Maximum 1000)
            FalsePositive = (Get-Random -Minimum 10 -Maximum 100)
            TrueNegative = (Get-Random -Minimum 100 -Maximum 1000)
            FalseNegative = (Get-Random -Minimum 10 -Maximum 100)
        }
    }

    # Export evaluation report
    $evaluationMetrics | ConvertTo-Json -Depth 5 | Out-File $EvaluationResults
}

Evaluate-MLModel -TrainedModel $ModelPath -TestData $TestDataPath -EvaluationResults $ResultsPath
'@
    },
    @{
        Name = "Data-Augmentation"
        Content = @'
param(
    [string]$InputDataPath,
    [string]$OutputDataPath,
    [int]$AugmentationFactor = 5
)

# Machine Learning Data Augmentation Script
function Augment-MLDataset {
    param(
        [string]$SourceData,
        [string]$AugmentedData,
        [int]$Factor
    )

    # Read original dataset
    $originalData = Import-Csv $SourceData

    # Augmentation strategies
    $augmentedDataset = @()

    for ($i = 0; $i -lt $Factor; $i++) {
        $currentAugmentation = $originalData | ForEach-Object {
            $row = $_
            
            # Different augmentation techniques
            switch ($i % 4) {
                0 { 
                    # Add small Gaussian noise
                    $numericColumns = $row.PSObject.Properties.Name | 
                        Where-Object { $row.$_ -match '^\d+(\.\d+)?$' }
                    
                    foreach ($col in $numericColumns) {
                        $noise = Get-Random -Minimum -0.1 -Maximum 0.1
                        $row.$col = [math]::Round([double]$row.$col + $noise, 4)
                    }
                }
                1 { 
                    # Randomly swap values between similar columns
                    $numericColumns = $row.PSObject.Properties.Name | 
                        Where-Object { $row.$_ -match '^\d+(\.\d+)?$' }
                    
                    if ($numericColumns.Count -gt 1) {
                        $col1, $col2 = $numericColumns | Get-Random -Count 2
                        $temp = $row.$col1
                        $row.$col1 = $row.$col2
                        $row.$col2 = $temp
                    }
                }
                2 { 
                    # Scale numeric features
                    $numericColumns = $row.PSObject.Properties.Name | 
                        Where-Object { $row.$_ -match '^\d+(\.\d+)?$' }
                    
                    foreach ($col in $numericColumns) {
                        $scaleFactor = Get-Random -Minimum 0.8 -Maximum 1.2
                        $row.$col = [math]::Round([double]$row.$col * $scaleFactor, 4)
                    }
                }
                3 { 
                    # Add categorical variation
                    $categoricalColumns = $row.PSObject.Properties.Name | 
                        Where-Object { $row.$_ -notmatch '^\d+(\.\d+)?$' }
                    
                    foreach ($col in $categoricalColumns) {
                        $variations = @("Low", "Medium", "High", "Unknown")
                        $row.$col = ($variations | Get-Random)
                    }
                }
            }
            
            $row
        }
        
        $augmentedDataset += $currentAugmentation
    }

    # Export augmented dataset
    $augmentedDataset | Export-Csv $AugmentedData -NoTypeInformation
}

Augment-MLDataset -SourceData $InputDataPath -AugmentedData $OutputDataPath -Factor $AugmentationFactor
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