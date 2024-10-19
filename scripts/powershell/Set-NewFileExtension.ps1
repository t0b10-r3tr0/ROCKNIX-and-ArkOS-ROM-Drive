param(
    [string]$directoryPath,     # The directory to perform the operation
    [string]$oldExtension,      # The file extension to be updated (e.g. .zip)
    [string]$newExtension,      # The new file extension to apply (e.g. .dosz)
    [switch]$r                  # Optional switch for recursive search
)

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: script.ps1 <directoryPath> <oldExtension> <newExtension> [-r]"
    Write-Host "Example: script.ps1 'C:\YourDirectory' '.zip' '.dosz' -r"
    Write-Host "Note: The -r switch is optional and enables recursive file search."
    exit
}

# Validate parameters
if (-not $directoryPath -or -not $oldExtension -or -not $newExtension) {
    Write-Host "Error: Missing required arguments."
    Show-Usage
}

# Check if the provided directory exists
if (-not (Test-Path -Path $directoryPath -PathType Container)) {
    Write-Host "Error: The specified directory does not exist."
    Show-Usage
}

# Define the search option based on the -r flag
$searchOption = if ($r) { 'Recurse' } else { 'TopDirectoryOnly' }

# Get all files with the old extension (recursively if -r is specified)
$files = Get-ChildItem -Path $directoryPath -Filter "*$oldExtension" -File -Recurse:$r

# Initialize a counter for the number of modified files
$modifiedFilesCount = 0

# Iterate through each file and rename it with the new extension
foreach ($file in $files) {
    $newName = [System.IO.Path]::ChangeExtension($file.FullName, $newExtension)
    Rename-Item -Path $file.FullName -NewName $newName
    $modifiedFilesCount++
    Write-Host "Renamed $($file.FullName) to $newName"
}

# Display the summary report
Write-Host "`nOperation completed. Modified $modifiedFilesCount files."
