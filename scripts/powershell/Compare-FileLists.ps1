# Save this script as Compare-FileLists.ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$File1,
    
    [Parameter(Mandatory = $true)]
    [string]$File2
)

# Ensure the files exist
if (-Not (Test-Path -Path $File1 -PathType Leaf)) {
    Write-Error "The file '$File1' does not exist."
    exit
}
if (-Not (Test-Path -Path $File2 -PathType Leaf)) {
    Write-Error "The file '$File2' does not exist."
    exit
}

# Read the contents of the files into arrays, trimming any whitespace and removing empty lines
$file1Content = Get-Content -Path $File1 -Encoding UTF8 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Sort-Object
$file2Content = Get-Content -Path $File2 -Encoding UTF8 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Sort-Object

# Debug output
Write-Host "`nContents of File1 ($File1):"
$file1Content
Write-Host "`nContents of File2 ($File2):"
$file2Content

# Items only in File1
$onlyInFile1 = $file1Content | Where-Object { $file2Content -notcontains $_ }

# Items only in File2
$onlyInFile2 = $file2Content | Where-Object { $file1Content -notcontains $_ }

# Items in both files
$inBoth = $file1Content | Where-Object { $file2Content -contains $_ }

# Output the results
Write-Host "`nItems only in '$File1':"
$onlyInFile1

Write-Host "`nItems only in '$File2':"
$onlyInFile2

Write-Host "`nItems in both '$File1' and '$File2':"
$inBoth
