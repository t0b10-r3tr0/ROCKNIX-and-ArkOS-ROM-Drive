param(
    [Parameter(Mandatory = $true)]
    [string[]]$Files,   # Input files containing directory lists
    [Parameter(Mandatory = $true)]
    [string]$DestinationDir,  # The directory where the structure will be created
    [Parameter(Mandatory = $false)]
    [string]$OriginalDirBasePath = "."  # The base path where original directories are stored
)

# Ensure the destination directory exists
if (-Not (Test-Path -Path $DestinationDir -PathType Container)) {
    try {
        New-Item -Path $DestinationDir -ItemType Directory -Force | Out-Null
        Write-Host "Created destination directory: $DestinationDir"
    } catch {
        Write-Error "Failed to create destination directory '$DestinationDir'. $_"
        exit
    }
}

# Collect all directories from all input files
$allDirectories = @{}
$filesContent = @{}

foreach ($file in $Files) {
    $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $directories = Get-Content -Path $file -Encoding UTF8 | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Sort-Object -Unique
    
    # Store the content of the file for later comparison
    $filesContent[$file] = $directories

    foreach ($dir in $directories) {
        if ($allDirectories.ContainsKey($dir)) {
            $allDirectories[$dir].Add($fileBaseName)
        } else {
            $allDirectories[$dir] = @($fileBaseName)
        }
    }
}

# Create directory structure and handle symbolic links
foreach ($dir in $allDirectories.Keys) {
    $sourcePaths = $allDirectories[$dir]

    $targetPath = Join-Path -Path $DestinationDir -ChildPath $dir

    # Check if the directory is common across multiple file lists
    if ($sourcePaths.Count -gt 1) {
        Write-Host "Directory '$dir' is common to: $($sourcePaths -join ', ')"
        
        # Choose the first source as the "real" directory to link to
        $realSourceFile = $Files | Where-Object { $_ -like "*$($sourcePaths[0])*" } | Select-Object -First 1
        $realSourcePath = Join-Path -Path $OriginalDirBasePath -ChildPath $dir
        
        if (-Not (Test-Path $realSourcePath)) {
            Write-Warning "Real source directory '$realSourcePath' does not exist. Skipping symbolic link."
            continue
        }

        try {
            # Create a symbolic link at the target location
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $realSourcePath -Force
            Write-Host "Created symbolic link for '$dir' pointing to '$realSourcePath'"
        } catch {
            Write-Error "Failed to create symbolic link for '$dir'. $_"
        }
    } else {
        Write-Host "Creating actual directory for '$dir'"
        # If it's unique, just create the directory
        try {
            New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
            Write-Host "Created directory '$dir'"
        } catch {
            Write-Error "Failed to create directory '$dir'. $_"
        }
    }
}

Write-Host "Directory structure created successfully at '$DestinationDir'."
