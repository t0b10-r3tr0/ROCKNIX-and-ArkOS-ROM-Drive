<#
.SYNOPSIS
    Compares the contents of two directories to identify items only in the first directory, only in the second directory, and items present in both.

.DESCRIPTION
    This script compares two directories and lists the items that are unique to each directory as well as the items that exist in both. It supports both non-recursive and recursive comparisons.

.PARAMETER Directory1
    The path to the first directory to compare. This parameter is mandatory.

.PARAMETER Directory2
    The path to the second directory to compare. This parameter is mandatory.

.PARAMETER Recurse
    A switch to enable recursive comparison of all subdirectories. This parameter is optional.

.PARAMETER OutputFile1
    The file path to which items only in Directory1 will be exported. Defaults to "OnlyInDirectory1.txt".

.PARAMETER OutputFile2
    The file path to which items only in Directory2 will be exported. Defaults to "OnlyInDirectory2.txt".

.PARAMETER OutputFileBoth
    The file path to which items present in both directories will be exported. Defaults to "InBothDirectories.txt".

.EXAMPLE
    .\Compare-Directories.ps1 -Directory1 "C:\Projects\ArkOS" -Directory2 "C:\Projects\ROCKNIX"

    Performs a non-recursive comparison between "ArkOS" and "ROCKNIX" directories.

.EXAMPLE
    .\Compare-Directories.ps1 -Directory1 "C:\Projects\ArkOS" -Directory2 "C:\Projects\ROCKNIX" -Recurse

    Performs a recursive comparison between "ArkOS" and "ROCKNIX" directories.

.EXAMPLE
    .\Compare-Directories.ps1 -Directory1 "C:\Projects\ArkOS" -Directory2 "C:\Projects\ROCKNIX" -Recurse -OutputFile1 "OnlyArkOS.txt" -OutputFile2 "OnlyROCKNIX.txt" -OutputFileBoth "InBoth.txt"

    Performs a recursive comparison and exports the results to specified files.

.NOTES
    Author: Your Name
    Date: YYYY-MM-DD
#>

param(
    [Parameter(Mandatory = $true, HelpMessage = "Specify the first directory to compare.")]
    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
    [string]$Directory1,

    [Parameter(Mandatory = $true, HelpMessage = "Specify the second directory to compare.")]
    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
    [string]$Directory2,

    [Parameter(Mandatory = $false, HelpMessage = "Use this switch to enable recursive comparison.")]
    [switch]$Recurse,

    [Parameter(Mandatory = $false, HelpMessage = "Specify the output file for items only in Directory1.")]
    [string]$OutputFile1 = "OnlyInDirectory1.txt",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the output file for items only in Directory2.")]
    [string]$OutputFile2 = "OnlyInDirectory2.txt",

    [Parameter(Mandatory = $false, HelpMessage = "Specify the output file for items present in both directories.")]
    [string]$OutputFileBoth = "InBothDirectories.txt"
)

# Function to get relative paths of items
function Get-RelativePath {
    param (
        [string]$FullPath,
        [string]$BasePath
    )
    $baseResolved = (Resolve-Path -Path $BasePath).Path
    $fullResolved = (Resolve-Path -Path $FullPath).Path
    return $fullResolved.Substring($baseResolved.Length).TrimStart('\')
}

try {
    # Determine if recursion is needed
    $recurseFlag = if ($Recurse) { $true } else { $false }

    Write-Host "Retrieving items from '$Directory1'..." -ForegroundColor Cyan
    $dir1Items = Get-ChildItem -Path $Directory1 -Recurse:$recurseFlag -ErrorAction Stop | Select-Object -ExpandProperty FullName

    Write-Host "Retrieving items from '$Directory2'..." -ForegroundColor Cyan
    $dir2Items = Get-ChildItem -Path $Directory2 -Recurse:$recurseFlag -ErrorAction Stop | Select-Object -ExpandProperty FullName

    # Convert full paths to relative paths for accurate comparison
    Write-Host "Processing relative paths..." -ForegroundColor Cyan
    $dir1Relative = $dir1Items | ForEach-Object { Get-RelativePath -FullPath $_ -BasePath $Directory1 }
    $dir2Relative = $dir2Items | ForEach-Object { Get-RelativePath -FullPath $_ -BasePath $Directory2 }

    # Compare the relative paths with -IncludeEqual to capture items present in both
    Write-Host "Comparing directories..." -ForegroundColor Cyan
    $comparison = Compare-Object -ReferenceObject $dir1Relative -DifferenceObject $dir2Relative -IncludeEqual

    # Extract items only in Directory1
    $onlyInDir1 = $comparison | Where-Object { $_.SideIndicator -eq "<=" } | Select-Object -ExpandProperty InputObject

    # Extract items only in Directory2
    $onlyInDir2 = $comparison | Where-Object { $_.SideIndicator -eq "=>" } | Select-Object -ExpandProperty InputObject

    # Extract items present in both directories
    $inBoth = $comparison | Where-Object { $_.SideIndicator -eq "==" } | Select-Object -ExpandProperty InputObject

    # Output the results to console
    Write-Host "Items only in '$Directory1':" -ForegroundColor Yellow
    if ($onlyInDir1) {
        $onlyInDir1 | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "None" -ForegroundColor Green
    }

    Write-Host "`nItems only in '$Directory2':" -ForegroundColor Yellow
    if ($onlyInDir2) {
        $onlyInDir2 | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "None" -ForegroundColor Green
    }

    Write-Host "`nItems in both '$Directory1' and '$Directory2':" -ForegroundColor Yellow
    if ($inBoth) {
        $inBoth | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "None" -ForegroundColor Green
    }

    # Export the results to files
    Write-Host "`nExporting results to files..." -ForegroundColor Cyan

    $onlyInDir1 | Out-File -FilePath $OutputFile1 -Encoding UTF8
    Write-Host "Exported items only in '$Directory1' to '$OutputFile1'." -ForegroundColor Green

    $onlyInDir2 | Out-File -FilePath $OutputFile2 -Encoding UTF8
    Write-Host "Exported items only in '$Directory2' to '$OutputFile2'." -ForegroundColor Green

    $inBoth | Out-File -FilePath $OutputFileBoth -Encoding UTF8
    Write-Host "Exported items present in both directories to '$OutputFileBoth'." -ForegroundColor Green

} catch {
    Write-Error "An error occurred: $_.Exception.Message"
    exit 1
}
