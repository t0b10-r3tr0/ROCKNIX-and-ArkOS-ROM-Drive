param (
    [Parameter(Mandatory=$true)]
    [string]$SourceDir,

    [Parameter(Mandatory=$true)]
    [string]$TargetDir
)

# Ensure target directory exists
if (-not (Test-Path -Path $TargetDir)) {
    New-Item -Path $TargetDir -ItemType Directory | Out-Null
}

# Function to compare two files and allow the user to choose
function Compare-And-Choose {
    param (
        [string]$SourceFile,
        [string]$TargetFile
    )

    $sourceInfo = Get-Item $SourceFile
    $targetInfo = Get-Item $TargetFile

    Write-Host "File conflict:"
    Write-Host "Source file: $($sourceInfo.FullName)"
    Write-Host "Size: $($sourceInfo.Length) bytes, Date modified: $($sourceInfo.LastWriteTime)"
    Write-Host "Target file: $($targetInfo.FullName)"
    Write-Host "Size: $($targetInfo.Length) bytes, Date modified: $($targetInfo.LastWriteTime)"

    $choice = Read-Host "Enter 'S' to keep the source file, 'T' to keep the target file, or 'C' to cancel"
    return $choice
}

# Recursively copy files from source to target directory, flattening structure
Get-ChildItem -Path $SourceDir -File -Recurse | ForEach-Object {
    $sourceFile = $_.FullName
    $targetFile = Join-Path -Path $TargetDir -ChildPath $_.Name

    if (Test-Path -Path $targetFile) {
        # File with the same name exists in the target directory
        $choice = Compare-And-Choose -SourceFile $sourceFile -TargetFile $targetFile

        switch ($choice.ToUpper()) {
            'S' {
                # Overwrite the target file with the source file
                Copy-Item -Path $sourceFile -Destination $targetFile -Force
                Write-Host "Source file copied: $sourceFile"
            }
            'T' {
                Write-Host "Target file kept: $targetFile"
            }
            'C' {
                Write-Host "Operation cancelled for file: $sourceFile"
            }
            Default {
                Write-Host "Invalid choice. Skipping file: $sourceFile"
            }
        }
    } else {
        # Copy the file since no conflict exists
        Copy-Item -Path $sourceFile -Destination $targetFile
        Write-Host "File copied: $sourceFile"
    }
}

Write-Host "File copying process completed."
