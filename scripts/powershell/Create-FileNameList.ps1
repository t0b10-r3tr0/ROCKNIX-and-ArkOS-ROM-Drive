param (
    [string]$DirectoryPath,
    [string]$OutputFile
)

# Check if the directory exists
if (-not (Test-Path $DirectoryPath)) {
    Write-Host "Directory not found: $DirectoryPath"
    exit 1
}

# Get all the files in the directory (non-recursive)
$files = Get-ChildItem -Path $DirectoryPath -File

# Extract just the file names (without paths) and write to the output file
$files.Name | Out-File -FilePath $OutputFile

Write-Host "File names have been written to: $OutputFile"
