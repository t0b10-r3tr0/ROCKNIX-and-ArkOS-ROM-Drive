param (
    [string]$directory1 = "C:\path\to\directory1", # Path to the first directory
    [string]$directory2 = "C:\path\to\directory2"  # Path to the second directory
)

# Check if both directories exist
if (-not (Test-Path $directory1)) {
    Write-Host "Directory1 does not exist: $directory1"
    exit
}
if (-not (Test-Path $directory2)) {
    Write-Host "Directory2 does not exist: $directory2"
    exit
}

# Get the list of files and directories in both directories (without recursion), showing only the names
$dir1Content = Get-ChildItem -Path $directory1 | Select-Object -ExpandProperty Name
$dir2Content = Get-ChildItem -Path $directory2 | Select-Object -ExpandProperty Name

# Find files/directories that are only in Directory1
$onlyInDir1 = Compare-Object -ReferenceObject $dir1Content -DifferenceObject $dir2Content -PassThru | Where-Object { $_.SideIndicator -eq "<=" }

# Find files/directories that are only in Directory2
$onlyInDir2 = Compare-Object -ReferenceObject $dir1Content -DifferenceObject $dir2Content -PassThru | Where-Object { $_.SideIndicator -eq "=>" }

# Find files/directories that exist in both directories
$inBoth = Compare-Object -ReferenceObject $dir1Content -DifferenceObject $dir2Content -PassThru | Where-Object { $_.SideIndicator -eq "==" }

# Output the results
Write-Host "Items only in $directory1:"
$onlyInDir1

Write-Host "`nItems only in $directory2:"
$onlyInDir2

Write-Host "`nItems in both $directory1 and $directory2:"
$inBoth
