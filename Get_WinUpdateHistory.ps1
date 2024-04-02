# Get the current date
$currentDate = Get-Date

# Get the date one year ago
$oneYearAgo = $currentDate.AddYears(-1)

# Read the machine names from the file
$machines = Get-Content -Path .\machines.txt

# Loop over each machine
foreach ($machine in $machines) {
    # Try to retrieve the updates
    try {
        # Get the updates installed on the machine
        $updates = Get-WmiObject -ComputerName $machine -Query "SELECT * FROM Win32_QuickFixEngineering" -ErrorAction Stop

        # Filter the updates to only include those installed in the last year
        $updates = $updates | Where-Object { $_.InstalledOn -as [datetime] -ge $oneYearAgo }

        # Create a new StringBuilder to store the output
        $output = New-Object -TypeName System.Text.StringBuilder

        # Output the updates
        foreach ($update in $updates) {
            # Convert the InstalledOn property to a DateTime object
            $installedOn = $update.InstalledOn -as [datetime]

            # Append the update information to the output
            $null = $output.AppendLine("Machine: $machine")
            $null = $output.AppendLine("Hotfix ID: $($update.HotFixID)")
            $null = $output.AppendLine("Title: $($update.Caption)")
            $null = $output.AppendLine("Installed On: $installedOn")
            $null = $output.AppendLine("------------------------")
        }

        # Export the output to a file
        $output.ToString() | Out-File -FilePath ".\$machine\$machine`_WinUpdateHistory.txt"
    }
    catch {
        # Output an error message if the updates could not be retrieved
        Write-Output "Failed to retrieve updates for machine '$machine': $($_.Exception.Message)"
    }
}