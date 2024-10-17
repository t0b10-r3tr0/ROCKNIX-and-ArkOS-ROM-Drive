# Define the path to the input file containing directory names
$inputFile = "filestolink.txt"

# Define the directory where the symbolic links should point (roms directory)
$romsDir = ".\roms"

# Read the directory names from the input file
$directoryNames = Get-Content $inputFile

# Iterate through each directory name in the file and create a symbolic link
foreach ($dirName in $directoryNames) {
    $targetPath = Join-Path $romsDir $dirName
    $command = "cmd /c mklink /d $dirName $targetPath"
    
    # Execute the mklink command
    Invoke-Expression $command

    Write-Host "Created symbolic link for: $dirName -> $targetPath"
}
