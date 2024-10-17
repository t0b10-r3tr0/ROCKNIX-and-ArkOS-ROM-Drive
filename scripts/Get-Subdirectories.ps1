# Save this script with a .ps1 extension, for example, Get-Subdirectories.ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$DirectoryPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "subdirectories.txt"
)

# Ensure the directory exists
if (-Not (Test-Path -Path $DirectoryPath -PathType Container)) {
    Write-Error "The directory path '$DirectoryPath' does not exist."
    exit
}

# Get immediate subdirectories
$subdirs = Get-ChildItem -Path $DirectoryPath -Directory

# Extract just the names of the directories
$subdirNames = $subdirs | Select-Object -ExpandProperty Name

# Write the directory names to the output file
$subdirNames | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Subdirectory names have been written to '$OutputFile'."
