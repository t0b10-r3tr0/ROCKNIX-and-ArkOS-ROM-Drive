# PowerShell & Bash Scripts

## File Extension Changer

It's as simple as it sounds. Searches for files of a specified extension and changes it to the provided new extension. can also optionally be perfomed recursively into subirectories.

### How it Works

The program take three manditory arguments and an optional switch, which are:

1. Directory to which the operation will be performed upon
2. Current file extension
3. New file extensions
- The `-r` switch will cause the script to perform the operation recurively into subdirectories. Use with caution.

### Example of Use

#### PowerShell 

##### Set-NewFileExtension.ps1

Without recursion:

```.\Set-NewFileExtension.ps1 "C:\YourDirectory" ".zip" ".dosz"```

With recursion:

```.\Set-NewFileExtension.ps1 -r "C:\YourDirectory" ".zip" ".dosz```

#### Bash:

##### rename_file_extensions.sh

Without recursion:

```./rename_file_extension.sh /path/to/directory .zip .dosz```

With recursion:

```./rename_file_extension.sh -r /path/to/directory .zip .dosz```

## Directory Flattener

### What it does

Transverses a directory, reccursively, copying all files into the target directory in a *flattened* structure. The files are copied without their existing directory structure and thus why the previous directory structure is *flattened*. If there are potential duplicates in the target directory, the user is provided basic file information and prompted on how to proceed.

#### This script provides the flexibility you need for handling file conflicts while flattening the source directory into a single target directory.

### How it works

The program takes two manditory arguments. They are:

1. The source directory from which to recurse and copy the files from
2. The target directory (flattened)

### Example of Use

#### PowerShell

##### Get-DirectoryFilesFlattened.ps1

```.\Get-DirectoryFilesFlattened.ps1 C:\FolderWithManySubfolders C:\FlattenedFolder```

## Directory Name File Creator

### What it does

This script tranverses the target directory and produces an output text file containing all of the directory names, each on a single line. Optionally, you can recurse into subdirectories as well which will add the relative path into the output of subdirectory names.

### How it works

The program takes two manditory arguments. They are:

1. The source directory is the first argument
2. The second argument is the file to write the output to

### Example of Use

#### PowerShell

##### Create-DirectoryNamesFile.ps1

```.\Create-DirectoryNamesFile.ps1 C:\Some\Directory directorynames.txt```

#### Bash

## Remove-FilesByExtension.ps1

### What it Does

It iterates over directories, optionally recursing based on the /r switch, and deletes files with the specified extensions.
If the /e switch is used, empty directories are removed after deleting the matching files.

### How it Works

The program requires at a minimum two arguments for the target directory and extension. The parameters are optional.

1. The target directory is the first argument.
2. Extensions follow as additional arguments.
- `-r` is a switch to enable recursion.
- `-e` is a switch to remove empty directories after file deletion.

### Example of Use

```.\Remove-FilesByExtension.ps1 C:\MyFolder .txt .log /r /e```