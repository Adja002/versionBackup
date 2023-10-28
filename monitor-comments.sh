#!/bin/bash

# Store the process ID of this script in a temporary file
echo $$ > /tmp/monitor_script.pid

# Define user-specific variables
USER_NAME="Adja Gueye"
STUDENT_NUMBER="s2110852"
Backup="/home/student/Desktop/Gueye_Adja_s2110852/versionBackup"

# Initialize flags and variables
stop_monitoring=false
status_message=""

# Define a marker file to check if the script is already running in a new terminal
MARKER_FILE="/tmp/.monitor_in_new_terminal"

# Check if the marker file doesn't exist (script is not running in a new terminal)
if [ ! -f "$MARKER_FILE" ]; then
    # Create the marker file
    touch "$MARKER_FILE"
    
    # Open a new terminal and execute this script to monitor in a separate terminal
    xfce4-terminal --command="$0"
    
    # Remove the marker file after the new terminal is launched
    rm "$MARKER_FILE"
    
    # Exit the current terminal
    exit 0
fi

# Function to capture user input and stop the monitoring if 'q' is pressed
user_input() {
    while true; do
        read -r -n 1 -s key
        if [[ $key == "q" ]]; then
            stop_monitoring=true
            break
        fi
    done
}

# Function to display ongoing monitoring dots
display_dots() {
    while true; do
        echo -n "Ongoing Monitoring..."
        sleep 1
        echo -e "\e[K"  # Clear the line
        sleep 1
    done
}

# Function to display the header information
display_header() {
    echo -e "\e[91m"  # Set text color to red
    echo "------------------------------------------------------------------"
    echo "Script enhanced by: $USER_NAME"
    echo "Student Number: $STUDENT_NUMBER"
    echo
    echo "Ongoing Monitoring..."
    echo "------------------------------------------------------------------"
}

# Function to display changes in the backup directory
display_changes() {
    local created="$1"
    local updated="$2"
    local deleted="$3"
    local time="$4"
    echo -e "\e[0m"  # Reset text color

    echo
    echo "total 0"
    ls -tl
    echo
    echo
    echo "Created     Updated     Deleted     Time"
    echo "-------     -------     -------     -----"
    printf "(%d) file(s) (%d) file(s) (%d) file(s) %s\n" "$created" "$updated" "$deleted" "$time"
    echo
    echo

    # Determine the status message based on changes in the backup directory
    if [ "$deleted" -gt 0 ]; then
        status_message="Status: $deleted file(s) was deleted in the versionBackup folder at $time."
    elif [ "$created" -gt 0 ]; then
        status_message="Status: $created file(s) was created in the versionBackup folder at $time."
    elif [ "$updated" -gt 0 ]; then
        status_message="Status: $updated file(s) was updated in the versionBackup folder at $time."
    else
        status_message="Status: No changes in the versionBackup folder in the last 15 seconds."
    fi

    echo -e "$status_message"
}

# Function to reset the status message
reset_changes_flag() {
    status_message=""
}

# Function to compare checksums of files to detect changes
compare_checksums() {
    local created=0
    local updated=0
    local deleted=0

    # Check if both checksum files exist
    if [ -f ".md5sum1" ] && [ -f ".md5sum2" ]; then
        # Calculate the number of updated files by comparing the checksums
        updated=$(diff --ignore-all-space <(sort .md5sum2) <(sort .md5sum1) | grep '<' | wc -l)
    fi

    local lines2=0
    local lines1=0

    # Check if the first checksum file exists
    if [ -f ".md5sum1" ]; then
        lines2=$(wc -l ".md5sum1" | awk '{ print $1 }')
    fi

    # Check if the second checksum file exists
    if [ -f ".md5sum2" ]; then
        lines1=$(wc -l ".md5sum2" | awk '{ print $1 }')
    fi

    # Calculate the number of created and deleted files based on line count differences
    if [ $lines1 -lt $lines2 ]; then
        created=$(($lines2 - $lines1))
    fi
    if [ $lines1 -gt $lines2 ]; then
        deleted=$(($lines1 - $lines2))
        updated=0
    fi

    # Display the changes
    display_changes "$created" "$updated" "$deleted" "$(date +'%T')"

    if [ -n "$status_message" ]; then
        # Wait for 15 seconds before resetting the status message
        sleep 15
        reset_changes_flag
    else
        echo "Status: No changes in the versionBackup folder in the last 15 seconds."
    fi
}

# Function to monitor the backup directory
monitor_directory() {
    clear
    display_header

    # Check if the backup directory does not exist
    if [ ! -d "$Backup" ]; then
        echo "Backup directory not found."
        return
    fi

    cd "$Backup"
    local items=$(ls 2>/dev/null)

    # Check if no files exist in the backup directory
    if [ -z "$items" ]; then
        echo "No files found in the backup directory."
        return
    fi

    # Check if the first checksum file exists and rename it
    if [ -f ".md5sum1" ]; then
        mv ".md5sum1" ".md5sum2"
    fi

    # Generate new checksums and compare changes
    md5sum $items > ".md5sum1"
    compare_checksums
}

# Main function to initiate monitoring
main() {
    clear
    display_header
    user_input &
    while true; do
        if $stop_monitoring; then
            echo "Stopping monitor. Goodbye!"
            exit 0
        fi
        monitor_directory
        sleep 15
    done
}

# Start monitoring
main

