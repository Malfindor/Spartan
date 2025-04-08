#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/SPARTAN
mv $repo_root/coreEasy.sh /etc/SPARTAN/coreEasy
chmod +x /etc/SPARTAN/coreEasy
mv $repo_root/coreMedium.sh /etc/SPARTAN/coreMedium
chmod +x /etc/SPARTAN/coreMedium
mv $repo_root/coreHard.sh /etc/SPARTAN/coreHard
chmod +x /etc/SPARTAN/coreHard
mv $repo_root/initializer.sh /etc/SPARTAN/initializer
chmod +x /etc/SPARTAN/initializer
touch /etc/SPARTAN/spartan.log
mv $repo_root/spartan.service /etc/systemd/system/spartan.service
systemctl daemon-reload
mv $repo_root/bin-control.sh /bin/spartan
chmod +x /bin/spartan
rm -rf $repo_root