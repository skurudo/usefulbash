#!/bin/bash
line=5
sed -e "${line}r gitlab_path_with_namespace.txt" config-template.yaml > config.yaml
