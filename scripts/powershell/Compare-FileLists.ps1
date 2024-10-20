# Save this script as Compare-FileLists.ps1

param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Alias("Path")]
    [string[]]$Files,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "."
)

# Function to write log messages
function Write-Log {
    param(
        [string]$Message,
        [string]$LogFile
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# Validate that at least two files are provided
if ($Files.Count -lt 2) {
    Write-Error "Please provide at least two file paths to compare."
    exit
}

# Ensure all specified files exist
foreach ($file in $Files) {
    if (-Not (Test-Path -Path $file -PathType Leaf)) {
        Write-Error "The file '$file' does not exist."
        exit
    }
}

# Create output directory if it doesn't exist
if (-Not (Test-Path -Path $OutputDirectory -PathType Container)) {
    try {
        New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
        Write-Host "Created output directory: $OutputDirectory"
    } catch {
        Write-Error "Failed to create output directory '$OutputDirectory'. $_"
        exit
    }
}

# Initialize log file
$logFile = Join-Path -Path $OutputDirectory -ChildPath "Compare-FileLists.log"
"Compare-FileLists Script Execution Log" | Out-File -FilePath $logFile -Encoding UTF8
Write-Log "Script started." $logFile

# Read and process contents of each file
$filesContent = @{}
foreach ($file in $Files) {
    Write-Log "Reading file: $file" $logFile
    try {
        $content = Get-Content -Path $file -Encoding UTF8 -ErrorAction Stop | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Sort-Object -Unique
        $filesContent[$file] = $content
    } catch {
        Write-Error "Failed to read file '$file'. Error: $_"
        Write-Log "Error reading file '$file': $_" $logFile
        exit
    }
}

# Aggregate all unique lines across all files
Write-Log "Aggregating all unique lines across all files." $logFile

# Corrected line: Flatten the collection of arrays into a single array
$allLines = $filesContent.Values | ForEach-Object { $_ } | Sort-Object -Unique

# Determine lines common to all files (intersection)
Write-Log "Determining lines common to all files." $logFile
$commonLines = $allLines
foreach ($file in $Files) {
    $commonLines = $commonLines | Where-Object { $filesContent[$file] -contains $_ }
}

# Write common lines to output file
$commonOutputFile = Join-Path -Path $OutputDirectory -ChildPath "Common_Lines_All_Files.txt"
$commonLines | Out-File -FilePath $commonOutputFile -Encoding UTF8
Write-Log "Common lines across all files written to: $commonOutputFile" $logFile

# Determine lines unique to each file
foreach ($file in $Files) {
    Write-Log "Determining lines unique to file: $file" $logFile
    # Lines in current file not present in any other file
    $otherFiles = $Files | Where-Object { $_ -ne $file }
    $uniqueLines = $filesContent[$file]
    foreach ($otherFile in $otherFiles) {
        $uniqueLines = $uniqueLines | Where-Object { $filesContent[$otherFile] -notcontains $_ }
    }
    
    # Define output file for unique lines
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $uniqueOutputFile = Join-Path -Path $OutputDirectory -ChildPath "${baseName}_Unique_Lines.txt"
    
    # Write unique lines to output file
    $uniqueLines | Out-File -FilePath $uniqueOutputFile -Encoding UTF8
    Write-Log "Unique lines for '$file' written to: $uniqueOutputFile" $logFile
}

# Optionally, determine lines present in some but not all files
# (This section is optional and can be uncommented if needed)
<#
Write-Log "Determining lines present in some but not all files." $logFile
$partialCommonLines = $allLines | Where-Object {
    $count = 0
    foreach ($file in $Files) {
        if ($filesContent[$file] -contains $_) { $count++ }
    }
    return ($count -gt 1 -and $count -lt $Files.Count)
}

$partialOutputFile = Join-Path -Path $OutputDirectory -ChildPath "Common_Lines_Some_Files.txt"
$partialCommonLines | Out-File -FilePath $partialOutputFile -Encoding UTF8
Write-Log "Lines present in some but not all files written to: $partialOutputFile" $logFile
#>

Write-Log "Comparison completed successfully." $logFile
Write-Host "Comparison results have been saved to the following files in '$OutputDirectory':"
Write-Host " - Common to all files: $commonOutputFile"
foreach ($file in $Files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    Write-Host " - Unique to '$file'    : $(Join-Path -Path $OutputDirectory -ChildPath "${baseName}_Unique_Lines.txt")"
}
Write-Host " - Log file            : $logFile"
