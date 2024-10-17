param (
    [string]$inputFile,  # Input file with directory names
    [string]$baseDir = ".\roms"  # Base directory to create the directories in (default is ".\roms")
)

# Check if the input file exists
if (-not (Test-Path $inputFile)) {
    Write-Host "Input file not found: $inputFile" -ForegroundColor Red
    exit
}

# Read the directory names from the input file
$directoryNames = Get-Content $inputFile

# Iterate through each directory name in the file and create the directory
foreach ($dirName in $directoryNames) {
    $newDirPath = Join-Path $baseDir $dirName
    
    # Create the directory if it doesn't already exist
    if (-not (Test-Path $newDirPath)) {
        New-Item -Path $newDirPath -ItemType Directory
        Write-Host "Created directory: $newDirPath"
    } else {
        Write-Host "Directory already exists: $newDirPath"
    }
}
