# Get the list of machines from a text file
$machines = Get-Content -Path "machines.txt"

# Loop through each machine
foreach ($machine in $machines) {
    # Try to get the BIOS information
    try {
        $bios = Get-WmiObject -Class Win32_BIOS -ComputerName $machine -ErrorAction Stop
    }
    catch {
        Write-Output "Failed to get BIOS information from $machine"
        continue
    }

    # Create a directory for the machine
    $dirPath = "./$($bios.PSComputerName)"
    if (!(Test-Path -Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath
    }

    # Create a file name for the BIOS information
    $fileName = "$dirPath/$($bios.PSComputerName)_BIOS_Info.txt"

    # Get the BIOS installation date
    $biosInstallDate = $bios.ReleaseDate

    # Export the BIOS information and installation date to a text file
    $bios | Out-File -FilePath $fileName
    Add-Content -Path $fileName -Value "BIOS Installation Date: $biosInstallDate"
}