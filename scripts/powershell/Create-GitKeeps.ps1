param (
    [string]$rootDir = "C:\path\to\your\directory" # Default directory path, can be changed when running the script
)

# Check if the root directory exists
if (-not (Test-Path $rootDir)) {
    Write-Host "The specified directory does not exist: $rootDir"
    exit
}

# Recursively get all directories starting from the root directory, including empty ones
$directories = Get-ChildItem -Path $rootDir -Recurse -Directory

foreach ($directory in $directories) {
    # Ensure the directory exists before proceeding
    if (-not (Test-Path $directory.FullName)) {
        Write-Host "Directory does not exist: $($directory.FullName)"
        continue
    }

    # Define the path for the .gitkeep file
    $gitkeepPath = Join-Path $directory.FullName ".gitkeep"

    # Check if the .gitkeep file already exists
    if (-not (Test-Path $gitkeepPath)) {
        try {
            # If not, create an empty .gitkeep file
            New-Item -Path $gitkeepPath -ItemType File -Force | Out-Null
            Write-Host "Created .gitkeep in $($directory.FullName)"
        } catch {
            Write-Host "Failed to create .gitkeep in $($directory.FullName): $($_.Exception.Message)"
        }
    } else {
        Write-Host ".gitkeep already exists in $($directory.FullName)"
    }
}

Write-Host "Operation completed."
