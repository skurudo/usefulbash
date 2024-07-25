#!/bin/bash
#
# Selecting and changing the environment
#
###############################################################

# clear screen
clear

# Define colors for the menu
RED="\e[31m"
GREEN="\e[32m"
WHITE="\e[97m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

# Define an array of menu options
options=("DEV" "PROD" "Not-sure" "Exit")

# Function to handle DEV
function DEV {
    echo -e "You selected ${GREEN} DEV ${ENDCOLOR}."
    cd /opt/terraform
    git pull
    cd /opt/terraform/dev
    yc resource-manager folder list
    yc config set folder-id some-folder-id
    export ACCESS_KEY=ACCESS_KEY
    export SECRET_KEY=SECRET_KEY
    echo -e "${GREEN} DEV environment selected ${ENDCOLOR}"
    cd /opt/terraform/dev
    $SHELL
    exit;
}

# Function to handle PROD
function PROD {
    echo -e "You selected ${RED} PROD$ ${ENDCOLOR}."
    cd /opt/terraform
    git pull
    cd /opt/terraform/prod
    yc resource-manager folder list
    yc config set folder-id some-folder-id
    export ACCESS_KEY=ACCESS_KEY
    export SECRET_KEY=SECRET_KEY
    echo -e "${RED} PROD environment selected ${ENDCOLOR}"
    cd /opt/terraform/prod
    $SHELL
    exit;
}

# Function to handle Not-sure
function Not-sure {
    echo -e ""
    echo -e "${WHITE} Well.. if you not sure... then quit and try again! ${ENDCOLOR}"
    exit;
}

# Display the menu and process user selection
PS3="Enter your choice and define environment: "
select option in "${options[@]}"; do
    case $option in
        "DEV")
            DEV
            ;;
        "PROD")
            PROD
            ;;
        "Not-sure")
            Not-sure
            ;;
        "Exit")
            break
            ;;
        *)
            echo -e "${YELLOW} Invalid option. Try again. ${ENDCOLOR}"
            ;;
    esac
done