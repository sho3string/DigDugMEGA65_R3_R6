$WorkingDirectory = Get-Location
$length = 56

	cls
	Write-Output " .------------------------."
	Write-Output " |Building Dig Dug ROMs   |"
	Write-Output " '------------------------'"

	New-Item -ItemType Directory -Path $WorkingDirectory"\arcade" -Force
	New-Item -ItemType Directory -Path $WorkingDirectory"\arcade\digdug" -Force

	Write-Output "Copying Dig Dug ROMs"
	# z80 main cpu
	# Define the file paths within the folder
	$files = @("$WorkingDirectory\dd1a.1", "$WorkingDirectory\dd1a.2", "$WorkingDirectory\dd1a.3", "$WorkingDirectory\dd1a.4")
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\digdug\rom1.rom"
	# Concatenate the files as binary data
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	
	# z80 sub cpu
	$files = @("$WorkingDirectory\dd1a.5", "$WorkingDirectory\dd1a.6")
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\digdug\rom2.rom"
	# Concatenate the files as binary data
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	
	# z80 sound cpu
	Copy-Item -Path $WorkingDirectory\dd1.7 -Destination $WorkingDirectory\arcade\digdug\rom3.rom

	Write-Output "Copying Gfx #2 ROMs"
	# Define the file paths within the folder
	$files = @("$WorkingDirectory\dd1.15", "$WorkingDirectory\dd1.14", "$WorkingDirectory\dd1.13", "$WorkingDirectory\dd1.12")
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\digdug\gfx2.rom"
	# Concatenate the files as binary data
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	
	Write-Output "Copying Gfx #3 ROM"
	Copy-Item -Path $WorkingDirectory\dd1.10b -Destination $WorkingDirectory\arcade\digdug\dd1.10b
	
	Write-Output "Copying Gfx #4 ROM"
	Copy-Item -Path $WorkingDirectory\dd1.11 -Destination $WorkingDirectory\arcade\digdug\dd1.11
	
	Write-Output "Copying font ROM"
	Copy-Item -Path $WorkingDirectory\dd1.9 -Destination $WorkingDirectory\arcade\digdug\dd1.9
	
	Write-Output "Copying font Sound PROM"
	Copy-Item -Path $WorkingDirectory\136007.110 -Destination $WorkingDirectory\arcade\digdug\136007.110

	Write-Output "Copying font Sprite PROM"
	Copy-Item -Path $WorkingDirectory\136007.111 -Destination $WorkingDirectory\arcade\digdug\136007.111
	
	Write-Output "Copying font Char PROM"
	Copy-Item -Path $WorkingDirectory\136007.112 -Destination $WorkingDirectory\arcade\digdug\136007.112

	Write-Output "Copying font Palette PROM"
	Copy-Item -Path $WorkingDirectory\136007.113 -Destination $WorkingDirectory\arcade\digdug\136007.113


	Write-Output "Generating blank config file"
	$bytes = New-Object byte[] $length
	for ($i = 0; $i -lt $bytes.Length; $i++) {
	$bytes[$i] = 0xFF
	}
	
	$output_file = Join-Path -Path $WorkingDirectory -ChildPath "arcade\digdug\ddcfg"
	$output_directory = [System.IO.Path]::GetDirectoryName($output_file)
	[System.IO.File]::WriteAllBytes($output_file,$bytes)

	Write-Output "All done!"