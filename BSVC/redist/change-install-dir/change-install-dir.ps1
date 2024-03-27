# Read in bsvc as array
$x = Get-Content .\UI\bsvc.tk
# Delete the file so no conflicts occur
Remove-Item .\UI\bsvc.tk
# Rewrite first line of file to contain new install path
$x[0] = "set install_dir {$pwd}"
# Save file with ANSI encoding because freeware cannot handle other encoding types
$x | Out-File -Encoding default .\UI\bsvc.tk