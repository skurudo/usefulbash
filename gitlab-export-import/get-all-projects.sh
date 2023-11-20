#!/bin/bash
GL_DOMAIN="https://your-url"
GL_TOKEN="sometoken"
for ((i=1; ; i+=1)); do
    contents=$(curl "$GL_DOMAIN/api/v4/projects?private_token=$GL_TOKEN&per_page=100&page=$i")
    if jq -e '. | length == 0' >/dev/null; then 
       break
    fi <<< "$contents"
    echo "$contents" | jq -r '.[].path_with_namespace' > gitlab_path_with_namespace.txt
done

# prepare to yamlification
sed -i -e 's/^/    - /' gitlab_path_with_namespace.txt
