Write-Host "Installing Necessary Vagrant Plugins"
if (Test-Path '.\.vagrant\machines\default\virtualbox\id') { <#-- already created machine. (run this first time only.) --#> return; }
$Installed = @(vagrant plugin list | % { $_ -replace ' \(.*, global\)' })

@(
  # A list Of plugins needed for vagrant to work (installs only plugins that aren't installed already.)
  "vagrant-disksize"
) | ? { $Installed.Contains($_) -ne $true } | % { vagrant plugin install $_ }