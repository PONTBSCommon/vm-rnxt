if (Test-Path '.\.vagrant\machines\default\virtualbox\id') {
  # already created machine. (run this first time only.)
  return;
}

# a collection of plugins necessary for the vagrant box.
Write-Host "Installing Necessary Vagrant Plugins"


$Installed = @(vagrant plugin list | % { $_ -replace ' \(.*, global\)' })

# A list Of plugins needed for vagrant to work (installs only plugins that aren't installed already.)
@(
  "vagrant-disksize",
  "vagrant-triggers"
) | ? { $Installed.Contains($_) -ne $true } | % { $VAGRANT_USE_VAGRANT_TRIGGERS = "VAGRANT_USE_VAGRANT_TRIGGERS"; vagrant plugin install $_ }