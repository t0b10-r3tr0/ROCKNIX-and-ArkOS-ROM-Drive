param (
    [Parameter(Mandatory=$true)]
    [string]$TargetDir,

    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Extensions,

    [switch]$r,  # Recursively delete files
    [switch]$e   # Remove empty directories
)

# Initialize counters
$directoriesProcessed = 0
$filesDeleted = 0
$emptyDirectoriesRemoved = 0

# Function to display usage message
function Show-Usage {
    Write-Host "Usage: .\DeleteFilesByExtension.ps1 <TargetDir> <Extensions> [/r] [/e]"
    Write-Host "Example: .\DeleteFilesByExtension.ps1 C:\MyFolder .txt .log /r /e"
    Write-Host "`tTargetDir: The directory to target for file deletion"
    Write-Host "`tExtensions: One or more file extensions to delete (e.g., .txt .log)"
    Write-Host "`t/r: (Optional) Recurse into subdirectories"
    Write-Host "`t/e: (Optional) Remove empty directories after file deletion"
    exit
}

# Validate parameters
if (-not (Test-Path -Path $TargetDir)) {
    Write-Host "Error: Target directory does not exist."
    Show-Usage
}

if ($Extensions.Count -eq 0) {
    Write-Host "Error: No file extensions provided."
    Show-Usage
}

# Function to delete files by extension
function Delete-FilesByExtension {
    param (
        [string]$Directory
    )

    # Get list of files in the directory with the specified extensions
    $filesToDelete = Get-ChildItem -Path $Directory -File | Where-Object {
        $Extensions -contains $_.Extension
    }

    # Delete each file
    foreach ($file in $filesToDelete) {
        Remove-Item -Path $file.FullName -Force
        Write-Host "Deleted: $($file.FullName)"
        $filesDeleted++
    }

    $directoriesProcessed++
}

# Function to remove empty directories
function Remove-EmptyDirectories {
    param (
        [string]$Directory
    )

    # Check if directory is empty
    if (-not (Get-ChildItem -Path $Directory -Recurse)) {
        Remove-Item -Path $Directory -Force
        Write-Host "Removed empty directory: $Directory"
        $emptyDirectoriesRemoved++
    }
}

# Get directories to process (with or without recursion)
$dirsToProcess = if ($r) {
    Get-ChildItem -Path $TargetDir -Directory -Recurse
} else {
    Get-ChildItem -Path $TargetDir -Directory
}

# Add the target directory to the directories to process
$dirsToProcess = $dirsToProcess + (Get-Item -Path $TargetDir)

# Process each directory
foreach ($dir in $dirsToProcess) {
    Delete-FilesByExtension -Directory $dir.FullName

    if ($e) {
        Remove-EmptyDirectories -Directory $dir.FullName
    }
}

# Report summary
Write-Host "`nSummary:"
Write-Host "Directories processed: $directoriesProcessed"
Write-Host "Files deleted: $filesDeleted"

if ($e) {
    Write-Host "Empty directories removed: $emptyDirectoriesRemoved"
}
