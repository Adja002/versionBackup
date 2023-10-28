#!/bin/bash

echo $$ > /tmp/monitor_script.pid

USER_NAME="Adja Gueye"
STUDENT_NUMBER="s2110852"
Backup="/home/student/Desktop/Gueye_Adja_s2110852/versionBackup"

stop_monitoring=false
status_message=""

MARKER_FILE="/tmp/.monitor_in_new_terminal"

if [ ! -f "$MARKER_FILE" ]; then
    touch "$MARKER_FILE"
    xfce4-terminal --command="$0"
    rm "$MARKER_FILE"
    exit 0
fi

user_input() {
    while true; do
        read -r -n 1 -s key
        if [[ $key == "q" ]]; then
            stop_monitoring=true
            break
        fi
    done
}

display_dots() {
    while true; do
        echo -n "Ongoing Monitoring..."
        sleep 1
        echo -e "\e[K"  # Clear the line
        sleep 1
    done
}

display_header() {
    echo -e "\e[91m"  # Set text color to red
    echo "------------------------------------------------------------------"
    echo "Script enhanced by: $USER_NAME"
    echo "Student Number: $STUDENT_NUMBER"
    echo
    echo "Ongoing Monitoring..."
    echo "------------------------------------------------------------------"
}

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

reset_changes_flag() {
    status_message=""
}

compare_checksums() {
    local created=0
    local updated=0
    local deleted=0

    if [ -f ".md5sum1" ] && [ -f ".md5sum2" ]; then
        updated=$(diff --ignore-all-space <(sort .md5sum2) <(sort .md5sum1) | grep '<' | wc -l)
    fi

    local lines2=0
    local lines1=0

    if [ -f ".md5sum1" ]; then
        lines2=$(wc -l ".md5sum1" | awk '{ print $1 }')
    fi
    if [ -f ".md5sum2" ]; then
        lines1=$(wc -l ".md5sum2" | awk '{ print $1 }')
    fi

    if [ $lines1 -lt $lines2 ]; then
        created=$(($lines2 - $lines1))
    fi
    if [ $lines1 -gt $lines2 ]; then
        deleted=$(($lines1 - $lines2))
        updated=0
    fi

    display_changes "$created" "$updated" "$deleted" "$(date +'%T')"

    if [ -n "$status_message" ]; then
        sleep 15
        reset_changes_flag
    else
        echo "Status: No changes in the versionBackup folder in the last 15 seconds."
    fi
}

monitor_directory() {
    clear
    display_header

    if [ ! -d "$Backup" ]; then
        echo "Backup directory not found."
        return
    fi

    cd "$Backup"
    local items=$(ls 2>/dev/null)

    if [ -z "$items" ]; then
        echo "No files found in the backup directory."
        return
    fi

    if [ -f ".md5sum1" ]; then
        mv ".md5sum1" ".md5sum2"
    fi

    md5sum $items > ".md5sum1"
    compare_checksums
}

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

main

