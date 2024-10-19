param(
    [Parameter(Mandatory = $true)]
    [string]$DirectoryPath
)

# Ensure the directory exists
if (-Not (Test-Path -Path $DirectoryPath -PathType Container)) {
    Write-Error "The directory path '$DirectoryPath' does not exist."
    exit
}

# Confirm before proceeding
$confirm = Read-Host "Are you sure you want to delete all contents of the subdirectories of '$DirectoryPath'? (Y/N)"
if ($confirm -notin @('Y', 'y', 'Yes', 'yes')) {
    Write-Host "Operation cancelled."
    exit
}

# Get immediate subdirectories
$subdirectories = Get-ChildItem -Path $DirectoryPath -Directory

foreach ($subdir in $subdirectories) {
    # Get all items in the subdirectory recursively
    $items = Get-ChildItem -Path $subdir.FullName -Recurse -Force

    if ($items) {
        # Delete all items recursively
        $items | Remove-Item -Recurse -Force
    }

    Write-Host "Cleared contents of '$($subdir.FullName)'"
}

Write-Host "All subdirectories of '$DirectoryPath' have been cleared."
