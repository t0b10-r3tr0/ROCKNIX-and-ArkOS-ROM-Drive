param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$TargetDirectory,
    
    [Parameter(Position = 1, Mandatory = $true)]
    [string]$FileExtension,

    [Parameter(Position = 2, Mandatory = $false)]
    [Alias("R")]
    [switch]$Recursive
)

# Check if target directory exists
if (-Not (Test-Path -Path $TargetDirectory -PathType Container)) {
    Write-Host "The directory '$TargetDirectory' does not exist."
    exit
}

# Get all files matching the specified extension, with optional recursion
$matchingFiles = if ($Recursive) {
    Get-ChildItem -Path $TargetDirectory -Filter "*$FileExtension" -File -Recurse
} else {
    Get-ChildItem -Path $TargetDirectory -Filter "*$FileExtension" -File
}

foreach ($file in $matchingFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
    
    # Find all files with the same base name (ignoring extension)
    $relatedFiles = Get-ChildItem -Path $file.DirectoryName -Recurse:$Recursive | Where-Object { 
        $_.Name -like "$baseName.*" -and $_.Extension -ne $FileExtension 
    }

    # Delete all related files with different extensions
    foreach ($relatedFile in $relatedFiles) {
        Write-Host "Deleting file: $($relatedFile.FullName)"
        Remove-Item $relatedFile.FullName -Force
    }
}

Write-Host "Cleanup complete."
