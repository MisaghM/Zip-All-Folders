
# Zip All Folders [![license](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/MisaghM/Zip-All-Folders/blob/main/LICENSE "Repository License")

## About

A collection of scripts that do the same thing in different languages.  
Zipping all folders in a directory to their own respective zip file.

## Usage

```text
ZipAllFolders.bat <path>
./ZipAllFolders.sh <path>
./ZipAllFolders.ps1 <path>
python ZipAllFolders.py <path>
```

`<path>` is optional. The current working directory is used if left empty.  
The script will prompt to remove the original folders,  
then proceed to zip all folders and report the progress and file size.

## Requirements

The Batch script requires [7-Zip](https://www.7-zip.org/) (7z.exe) to be in the environment PATH.  
The Bash script requires the `zip` command.  
*The Powershell and Python scripts use built-in modules to zip.*
