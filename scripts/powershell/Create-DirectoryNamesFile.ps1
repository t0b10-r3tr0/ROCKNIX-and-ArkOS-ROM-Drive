param(
    [Parameter(Mandatory = $true)]
    [string]$DirectoryPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "subdirectories.txt",

    [switch]$Recursive
)

# Ensure the directory exists
if (-Not (Test-Path -Path $DirectoryPath -PathType Container)) {
    Write-Error "The directory path '$DirectoryPath' does not exist."
    exit
}

# Normalize the directory path (ensure no trailing backslash)
$DirectoryPath = [System.IO.Path]::GetFullPath($DirectoryPath).TrimEnd('\')

# Get subdirectories based on the -r switch
if ($Recursive) {
    # Get all subdirectories recursively
    $subdirs = Get-ChildItem -Path $DirectoryPath -Directory -Recurse
} else {
    # Get immediate subdirectories only
    $subdirs = Get-ChildItem -Path $DirectoryPath -Directory
}

# Extract just the relative paths of the directories
$subdirNames = $subdirs | ForEach-Object {
    # Use relative path calculation, remove the base DirectoryPath
    $relativePath = $_.FullName.Substring($DirectoryPath.Length + 1)
    $relativePath
}

# Write the directory names to the output file
$subdirNames | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Subdirectory names have been written to '$OutputFile'."
