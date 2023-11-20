#!/bin/bash
#
# https://github.com/rvojcik/gitlab-project-export
### pip install gitlab-project-export
#
# get all projects from gitlab
echo "Getting projects names"
bash get-all-projects.sh
# create config for exporter
echo "Greating config file for gitlab-project-export"
bash config-creation.sh
# do the thing
echo "Exporting"
gitlab-project-export.py -d -f -c config.yaml

