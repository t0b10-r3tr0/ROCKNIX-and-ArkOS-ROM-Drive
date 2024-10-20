param (
    [string]$DirectoryPath,
    [string]$OutputFile,
    [switch]$Recursive  # Optional -r switch
)

# Check if the directory exists
if (-not (Test-Path $DirectoryPath)) {
    Write-Host "Directory not found: $DirectoryPath"
    exit 1
}

# Normalize the directory path (remove trailing slashes if present)
$DirectoryPath = (Get-Item -LiteralPath $DirectoryPath).FullName

# Get the files (recursively or non-recursively)
if ($Recursive) {
    # Recursive file listing with relative paths
    $files = Get-ChildItem -Path $DirectoryPath -File -Recurse | ForEach-Object {
        # Calculate relative path by removing the directory path from the full path
        $_.FullName.Substring($DirectoryPath.Length).TrimStart('\')
    }
} else {
    # Non-recursive file listing with relative paths
    $files = Get-ChildItem -Path $DirectoryPath -File | ForEach-Object {
        $_.FullName.Substring($DirectoryPath.Length).TrimStart('\')
    }
}

# Write the file paths (or names) to the output file
$files | Out-File -FilePath $OutputFile

Write-Host "Relative file paths have been written to: $OutputFile"
