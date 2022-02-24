<#
.SYNOPSIS
Zips all folders.
.DESCRIPTION
This script zips all the folders in the directory given in the first command-line argument.
(or the current working directory if the arg is left empty)
.PARAMETER Location
Specifies the path to zip all the folders in it.
#>

param (
    [Parameter(Position = 0)]
    [string]$Location = "."
)

Push-Location $Location
if (!$?) { exit 1 }

function Get-Choice {
    <#
    .SYNOPSIS
    Get a yes/no choice from the user.
    .PARAMETER Prompt
    The question to display.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]$Prompt
    )

    while ($true) {
        Write-Host -NoNewline "$Prompt [Y,N] "
        do {
            $Choice = $Host.UI.RawUI.ReadKey()
        } until ($Choice.Character)
        Write-Host ""

        switch ($Choice.Character) {
            'Y'     { return $true }
            'N'     { return $false }
            default { Write-Host "Invalid input." }
        }
    }
}

function Pause-Host {
    <#
    .SYNOPSIS
    Wait for keypress.
    .PARAMETER Message
    The message to display while waiting.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string]$Message
    )

    Write-Host -NoNewline $Message
    do {
        $Key = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    } until ($Key.Character)
    Write-Host ""
}

function Pretty-Size {
    <#
    .SYNOPSIS
    Get human-readable size from bytes.
    .PARAMETER Size
    Size in bytes.
    .PARAMETER Precision
    Precision for the result.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [uint64]$Size,
        [Parameter()]
        [uint32]$Precision = 2
    )
    begin {
        [string]$Format = "{0:F${Precision}} {1}"
    }
    process {
        switch ($Size) {
            { $PSItem -ge 1TB } { return $Format -f ($Size / 1TB), "TB" }
            { $PSItem -ge 1GB } { return $Format -f ($Size / 1GB), "GB" }
            { $PSItem -ge 1MB } { return $Format -f ($Size / 1MB), "MB" }
            { $PSItem -ge 1KB } { return $Format -f ($Size / 1KB), "KB" }
            default             { return "$Size B" }
        }
    }
}

[bool]$RmFolders = Get-Choice "Remove original folders?"
Write-Host ""

[int]$Count = 0
try {
    Get-ChildItem -Directory |
    ForEach-Object {
        ++$Count
        Write-Host "Folder ${Count}: $($PSItem.Name)"

        $ZipName = "$($PSItem.Name).zip"
        Compress-Archive -CompressionLevel NoCompression `
                         -DestinationPath $ZipName `
                         -Path "$($PSItem.Name)\*" `
                         -Update

        if (!(Test-Path $ZipName)) {
            Write-Host "Folder is empty.`n"
            return
        }

        Write-Host "Size ~ $($($(Get-Item $ZipName).Length) | Pretty-Size)"

        if ($RmFolders) {
            Remove-Item -Recurse -Force $PSItem.Name
            Write-Host "Folder deleted."
        }

        Write-Host ""
    }
}
catch {
    Write-Host -ForegroundColor Red "Error occurred during the process:"
    Write-Host $PSItem
    exit 1
}
finally {
    Pop-Location
}

Write-Host "Done."
Pause-Host "Press any key to continue . . . "
exit 0
