#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/SPARTAN
mv $repo_root/core.sh /etc/SPARTAN/core
chmod +x /etc/SPARTAN/core
mv $repo_root/initializer.sh /etc/SPARTAN/initializer
chmod +x /etc/SPARTAN/initializer
mv $repo_root/spartan.service /etc/systemd/system/spartan.service
systemctl daemon-reload
mv $repo_root/bin-control.sh /bin/spartan
chmod +x /bin/spartan
rm -rf $repo_root