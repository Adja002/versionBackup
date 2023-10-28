#!/bin/bash

# Define my information variaables
USER_NAME="Adja Gueye"
STUDENT_NUMBER="s2110852"
BACKUP_DIRECTORY="/home/student/Desktop/Gueye_Adja_s2110852/versionBackup"

# Display my information
echo "---------------------------"
echo "Name: $USER_NAME"
echo "Student Number: $STUDENT_NUMBER"
echo "---------------------------"

# Ensure BACKUP_DIRECTORY exists or create it
if [[ ! -d "$BACKUP_DIRECTORY" ]]; then
    mkdir -p "$BACKUP_DIRECTORY"
fi

# This function will back up the given files by appending version numbers.
backup_files() {
    for file in "$@"; do
        # Check if the file exists and is a regular file
        if [[ -f $file ]]; then
            base_file=$(basename "$file")
            version=1
            # Find the next available version number
            while [[ -f "$BACKUP_DIRECTORY/$base_file.$version" ]]; do
                version=$((version + 1))
            done
            new_versioned_file="$base_file.$version"  # Remove the path from the new versioned file
            cp "$file" "$BACKUP_DIRECTORY/$new_versioned_file"
            # Provide feedback on the backup process
            echo "File '$base_file' backed up as '$new_versioned_file'"
        else
            # Handle cases where the file is not found or is not a regular file
            echo "File '$file' not found or is not a regular file."
        fi
    done
}

# SIGINT trap
trap ctrl_c2 SIGINT

# Function to handle SIGINT signal
ctrl_c2() {
    files_count=0
    if [ -e "$BACKUP_DIRECTORY" ]; then
        cd "$BACKUP_DIRECTORY"
        files_count=$(find -type f | wc -l)
        # Display the total number of backed up files in the backup directory
        echo
        echo "Total number of backed up files in backup Directory = $files_count"
    else
        # Handle cases where the backup directory does not exist
        echo "Backup Directory does not exist"
    fi
    # Exit the script with status 130
    echo "Goodbye and thank you!"
    exit 130
}

list_files() {
    if [[ ! -d "$BACKUP_DIRECTORY" ]]; then
        echo "Backup directory not found."
        return
    fi

    cd "$BACKUP_DIRECTORY"
    file_count=0  # Initialize a counter for files

    # Display header
    echo "Here are the files in your backup directory"
    
    # Iterate through the files
    for file in .[^.]* *; do
        if [[ -f "$file" ]]; then
            size=$(stat -c %s "$file")  
            echo "File Name: $file | Size: $size bytes | Type: Regular File"
            ((file_count++))
        fi
    done

    if [[ $file_count -eq 0 ]]; then
        echo "No files found in the backup directory."
    else
        echo "-----------------------------------------------------------"
    fi
}


#Recover a specified file from the backup directory.
recover_file() {
    if [[ -f "$BACKUP_DIRECTORY/$1" ]]; then
        cp "$BACKUP_DIRECTORY/$1" "/home/student/"
        # Provide feedback on the recovery process
        echo "-----------------------------------------------------------"
        echo "File recovered to /home/student/$1"
        echo "-----------------------------------------------------------"
    else
        # Handle cases where the specified file is not found in the backup
        echo "File not found in the backup."
    fi
}

#Delete contents of the backup directory.
delete_contents() {
    echo "------------------------------------------------------------------------"
    echo "Are you sure you want to delete the contents of $BACKUP_DIRECTORY? (yes/no)"
    echo "------------------------------------------------------------------------"
    read response
    if [[ $response == "yes" ]]; then
        # Remove all files in the backup directory
        rm -rf "$BACKUP_DIRECTORY"/*
        # Provide feedback on the deletion process
        echo "------------------"
        echo "The contents have been deleted."
        echo "------------------"
    else
        # Handle cases where deletion is canceled
        echo "-------------------"
        echo "The deletion has been cancelled."
        echo "-------------------"
    fi
}

#Display total usage of the backup directory in bytes.
total_usage() {
    # Calculate and display the total disk usage of the backup directory
    echo "------------------------------------------------------------"
    echo "The total usage: $(du -sb $BACKUP_DIRECTORY | cut -f1) bytes"
    echo "------------------------------------------------------------"
}

# Function to check the disk usage in the versionBackup directory
check_directory_size() {
    size=$(du -sb "$BACKUP_DIRECTORY" | cut -f1)
    if (( size > 1024 )); then
        # Print a warning if the disk usage exceeds 1Kbytes
        echo "-------------------------------------------------------------------"
        echo "Warning: Disk usage in the versionBackup directory exceeds 1Kbytes."
        echo "-------------------------------------------------------------------"
    fi
    echo "Total usage: $size bytes"
}

#Call the monitor script.
start_monitor() {
    # Start the monitor script in a new XFCE terminal window
    xfce4-terminal --command="./monitor.sh" &
}

#Terminate the monitor script.
kill_monitor() {
    # Terminate the monitor script by searching and killing the process
    pkill -f "monitor.sh"
}

# Usage information
USAGE="usage: $0 -l -r <file> -d -t -m -k"

# Parse command-line options
while getopts :lr:dtmk args
do
  case $args in
     l) list_files ;;
     r) recover_file "$OPTARG" ;;
     d) delete_contents ;;
     t) total_usage ;;
     m) start_monitor ;;
     k) kill_monitor ;;
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
  esac
done

# Determine the number of positional parameters
((pos = OPTIND - 1))
shift $pos

PS3='option> '

# If there are remaining positional parameters, call backup_files for them
if (( $# > 0 ))
then
    backup_files "$@"
else
    # If no positional parameters, display a menu for user interaction
    if (( $OPTIND == 1 )); then 
        select menu_list in list recover delete total monitor kill exit
        do 
            case $menu_list in
                "list") list_files ;;
                "recover") echo "Enter filename to recover: "; read filename; recover_file "$filename" ;;
                "delete") delete_contents ;;
                "total") total_usage ;;
                "monitor") start_monitor ;;
                "kill") kill_monitor ;;
                "exit") exit 0;;
                *) echo "unknown option";;
            esac
        done
    fi
fi


