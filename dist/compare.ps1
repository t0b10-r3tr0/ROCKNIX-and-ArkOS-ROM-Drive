# Define the paths of the two directories you want to compare
$directory1 = "ArkOS"
$directory2 = "ROCKNIX"

# Get the list of files and directories in both directories (without recursion), showing only the names
$dir1Content = Get-ChildItem -Path $directory1 | Select-Object Name
$dir2Content = Get-ChildItem -Path $directory2 | Select-Object Name

# Find files/directories that are only in Directory1
$onlyInDir1 = Compare-Object -ReferenceObject $dir1Content.Name -DifferenceObject $dir2Content.Name -PassThru | Where-Object { $_.SideIndicator -eq "<=" }

# Find files/directories that are only in Directory2
$onlyInDir2 = Compare-Object -ReferenceObject $dir1Content.Name -DifferenceObject $dir2Content.Name -PassThru | Where-Object { $_.SideIndicator -eq "=>" }

# Find files/directories that exist in both directories
$inBoth = Compare-Object -ReferenceObject $dir1Content.Name -DifferenceObject $dir2Content.Name -PassThru | Where-Object { $_.SideIndicator -eq "==" }

# Alternatively, we can manually check for common items
$commonItems = $dir1Content.Name | Where-Object { $dir2Content.Name -contains $_ }

# Output the results
Write-Host "Items only in ${directory1}:"
$onlyInDir1

Write-Host "`nItems only in ${directory2}:"
$onlyInDir2

Write-Host "`nItems in both ${directory1} and ${directory2}:"
$commonItems