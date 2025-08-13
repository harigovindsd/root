<#
    File:          SharedFunctions.ps1
    Author:        hgovind_HEone
    Created:       2025-07-24
    Last Updated:  2025-07-24
    Version:       1.0.0

    Usage:
        # Dot-source to load:
        . "$PSScriptRoot\SharedFunctions.ps1"

    Notes:
				- PowerShell 5.1+ (works in PowerShell 7+).
        - HELP Example: Use Get-Help Get-SortedReleaseVersions -Full for detailed help once loaded.
#>

<#
.SYNOPSIS
    Retrieves release branch versions and outputs them sorted numerically.

.DESCRIPTION
    Enumerates all local and remote git branches (via 'git branch -a'), filters those
    containing the specified prefix (default 'release-'), and extracts the trailing
    dotted numeric version portion. Each dotted segment is zero-padded to 5 digits
    to create a lexical SortKey ensuring correct numeric ordering (e.g. 2.10 > 2.9).
    The original (unpadded) version strings are then emitted in ascending order.

.PARAMETER Prefix
    Branch name prefix to match (e.g. 'release-' to match 'origin/release-1.2.3').
    Only branches whose names end with a dotted numeric sequence after the prefix
    are considered.

.OUTPUTS
    [string]  One or more version strings (without the prefix), sorted ascending.

.EXAMPLES
    PS> Get-SortedReleaseVersions
    1.0
    1.2
    2.0.1

    PS> Get-SortedReleaseVersions -Prefix 'rel-'
    Returns versions from branches like origin/rel-3.4.5.

.NOTES
    - Regex currently matches only digits and dots: "$Prefix([\d\.]+)$"
      so pre-release identifiers (e.g., 1.2.0-rc1) are ignored.
    - To support semantic versions with labels, extend parsing logic.
    - Depends on the output format of 'git branch -a'.

#>
function Get-SortedReleaseVersions {
    param (
        [string]$Prefix = "release-"
    )

    git branch -a |
            Select-String "remote.*/$Prefix" |
            ForEach-Object {
                if ($_ -match "$Prefix([\d\.]+)$") {
                    $version = $matches[1]
                    # Normalizing version integer to fixed-width parts for correct sorting
                    # For example:
                    # 5.3 → 00005.00003
                    # 25.2 → 00025.00002
                    # 24.2.1.3 → 00024.00002.00001.00003
                    # TODO: Test for versions with non-numeric parts
                    $normalized = ($version.Split('.') | ForEach-Object { '{0:D5}' -f [int]$_ }) -join '.'
                    [PSCustomObject]@{
                        Version = $version
                        SortKey = $normalized
                    }
                }
            } |
            Sort-Object SortKey |
            Select-Object -ExpandProperty Version
}

<#
.SYNOPSIS
    Displays a grid-style numbered menu of options and returns the user's selection (almost working alternative to `select` in Shell.)

.DESCRIPTION
    Renders the provided options in a columnar grid whose column count is derived
    from the current console width divided by a fixed item width (25 characters).
    Items are filled vertically per column (row first across columns) to optimize
    space usage. The user is prompted to enter the number corresponding to an
    option. With -AllowQuit, a 0) Quit entry allows returning $null.

.PARAMETER Options
    Array of strings representing selectable items.

.PARAMETER Prompt
    Text displayed above the grid before each selection attempt.
    Defaults to: "Please select an option:"

.PARAMETER AllowQuit
    When specified, adds a "0) Quit" option that returns $null if chosen.

.OUTPUTS
    [string] The selected option string.
    [null]  If -AllowQuit is specified and the user selects Quit.

.EXAMPLES
    PS> Select-GridMenu -Options @('Alpha','Beta','Gamma')
    (Prompts user and returns selected string.)

    PS> $choice = Select-GridMenu -Options (1..12 | ForEach-Object {"Item$_"}) -Prompt "Pick one:" -AllowQuit
    PS> if ($null -eq $choice) { "User canceled." }

.NOTES
    - Input validation ensures the entered number maps to an existing option.
    - Uses [console]::WindowWidth; non-interactive hosts may not render properly.
    - Ordering strategy is vertical fill; adjust logic if horizontal fill is preferred.

#>
function Select-GridMenu {
    param (
        [string[]]$Options,
        [string]$Prompt = "Please select an option:",
        [switch]$AllowQuit
    )

    $consoleWidth = [console]::WindowWidth
    $itemWidth = 25
    $columns = [math]::Floor($consoleWidth / $itemWidth)
    if ($columns -lt 1) { $columns = 1 }
    $rows = [math]::Ceiling($Options.Count / $columns)

    do {
        Write-Host "`n$Prompt"
        $numberToIndex = @{}
        # Display vertically: for each row, print all columns in that row
        for ($row = 0; $row -lt $rows; $row++) {
            for ($col = 0; $col -lt $columns; $col++) {
                $index = ($row) + ($col * $rows)
                if ($index -lt $Options.Count) {
                    $menuNumber = $index + 1
                    $label = "{0,3}) {1,-20}" -f $menuNumber, $Options[$index]
                    Write-Host -NoNewline $label
                    $numberToIndex[$menuNumber] = $index
                }
            }
            Write-Host
        }

        if ($AllowQuit) {
            Write-Host "  0) Quit"
        }

        $choice = Read-Host "Enter the number of your choice"

        if ($AllowQuit -and $choice -eq '0') {
            return $null
        }
        $choiceInt = 0
        if ([int]::TryParse($choice, [ref]$choiceInt) -and $choiceInt -ge 1 -and $choiceInt -le $Options.Count) {
            return $Options[$choiceInt - 1]
        } else {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
        }
    } while ($true)
}
