# remove the old wander repos.
if (Test-Path ./git/ops) { rm -r -Force ./git/ops }
if (Test-Path ./git/wander) { rm -r -Force ./git/wander }