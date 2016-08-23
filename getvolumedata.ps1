Param(
  [Parameter(Mandatory=$true)][string]$volumeLabel,
  [Parameter(Mandatory=$true)][string]$percentageWarning,
  [Parameter(Mandatory=$true)][string]$percentageError
)


Try {
$vol = Get-Volume -FileSystemLabel $volumeLabel -ErrorAction Stop
}
Catch {
  Write-Host "UNKNOWN: No volume with label '$volumeLabel' found"
  Exit 3
}

$totSize = $vol.Size
$totSizeGB = "{0:N2}" -f [math]::Round(([long]$totSize / 1073741824),2)
$freeSize = $vol.SizeRemaining
$freeSizeGB = "{0:N2}" -f [math]::Round(([long]$freeSize / 1073741824), 2)
$usedSize = $totSize - $freeSize
$usedSizeGB = "{0:N2}" -f [math]::Round(([long]$usedSize / 1073741824), 2)
$percentageUsed = [math]::Round(([long]$usedSize / [long]$totSize) * 100)
$percentageFree = 100 - $percentageUsed
$warnSizeGB = "{0:N2}" -f [math]::Round((([long]$totSize * $percentageWarning * 0.01) / 1073741824), 2)
$errorSizeGB = "{0:N2}" -f [math]::Round((([long]$totSize * $percentageError * 0.01) / 1073741824), 2)

if ($percentageUsed -gt $percentageError) {
  Write-Host "CRITICAL: '$volumeLabel' - total: $totSizeGB Gb - used: $usedSizeGB GB ($percentageUsed%) - free $freeSizeGB Gb ($percentageFree%) | '${volumeLabel}: Used Space'=${usedSizeGB}GB;${warnSizeGB};${errorSizeGB};0,00;${totSizeGB}"
  Exit 2
}
elseif ($percentageUsed -gt $percentageWarning) {
  Write-Host "WARNING: '$volumeLabel' - total: $totSizeGB Gb - used: $usedSizeGB GB ($percentageUsed%) - free $freeSizeGB Gb ($percentageFree%) | '${volumeLabel}: Used Space'=${usedSizeGB}GB;${warnSizeGB};${errorSizeGB};0,00;${totSizeGB}"
  Exit 1
}
else {
  Write-Host "OK: '$volumeLabel' - total: $totSizeGB Gb - used: $usedSizeGB GB ($percentageUsed%) - free $freeSizeGB Gb ($percentageFree%) | '${volumeLabel}: Used Space'=${usedSizeGB}GB;${warnSizeGB};${errorSizeGB};0,00;${totSizeGB}"
  Exit 0
}

