 #! /bin/bash

USER_NAME="Adja Gueye"
STUDENT_NUMBER="s2110852"
BACKUP_DIRECTORY="/home/student/Desktop/Gueye_Adja_s2110852/versionBackup"

echo "---------------------------"
echo "Name: $USER_NAME"
echo "Student Number: $STUDENT_NUMBER"
echo "---------------------------"

if [[ ! -d "$BACKUP_DIRECTORY" ]]; then
    mkdir -p "$BACKUP_DIRECTORY"
fi


backup_files() {
    for file in "$@"; do
        if [[ -f $file ]]; then
            base_file=$(basename "$file")
            version=1
            while [[ -f "$BACKUP_DIRECTORY/$base_file.$version" ]]; do
                version=$((version + 1))
            done
            new_versioned_file="$base_file.$version"  
            cp "$file" "$BACKUP_DIRECTORY/$new_versioned_file"
            echo "File '$base_file' backed up as '$new_versioned_file'"
        else
            echo "File '$file' not found or is not a regular file."
        fi
    done
}


trap ctrl_c2 SIGINT

ctrl_c2() {
    files_count=0
    if [ -e "$BACKUP_DIRECTORY" ]; then
        cd "$BACKUP_DIRECTORY"
        files_count=$(find -type f | wc -l)
        echo
        echo "Total number of backed up files in backup Directory = $files_count"
    else
        echo "Backup Directory does not exist"
    fi
    echo "Goodbye and thank you!"
    exit 130
}



list_files() {
    if [[ ! -d "$BACKUP_DIRECTORY" ]]; then
        echo "Backup directory not found."
        return
    fi

    cd "$BACKUP_DIRECTORY"
    file_count=0  

    echo "Here are the files in your backup directory:"
    
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




recover_file() {
    if [[ -f "$BACKUP_DIRECTORY/$1" ]]; then
        cp "$BACKUP_DIRECTORY/$1" "/home/student/"
        echo "-----------------------------------------------------------"
        echo "File recovered to /home/student/$1"
        echo "-----------------------------------------------------------"
    else
        echo "File not found in backup."
    fi
}



delete_contents() {
    echo "------------------------------------------------------------------------"
    echo "Are you sure you want to delete the contents of $BACKUP_DIRECTORY? (yes/no)"
    echo "------------------------------------------------------------------------"
    read response
    if [[ $response == "yes" ]]; then
        rm -rf "$BACKUP_DIRECTORY"/*
        echo "------------------"
        echo "The contents have been deleted."
        echo "------------------"
    else
        echo "-------------------"
        echo "The deletion has been cancelled."
        echo "-------------------"
    fi
}


total_usage() {
    echo "------------------------------------------------------------"
    echo "The total usage: $(du -sb $BACKUP_DIRECTORY | cut -f1) bytes"
    echo "------------------------------------------------------------"
}

check_directory_size() {
    size=$(du -sb "$BACKUP_DIRECTORY" | cut -f1)
    if (( size > 1024 )); then
        echo "-------------------------------------------------------------------"
        echo "Warning: Disk usage in the versionBackup directory exceeds 1Kbytes."
        echo "-------------------------------------------------------------------"
    fi
}


start_monitor() {
    
    xfce4-terminal --command="./monitor.sh" &
}


kill_monitor() {
  pkill -f "monitor.sh"

}


check_directory_size() {
    size=$(du -sb "$BACKUP_DIRECTORY" | cut -f1)
    if (( size > 1024 )); then
        echo "-------------------------------------------------------------------"
        echo "Warning: Disk usage in the versionBackup directory exceeds 1Kbytes."
        echo "-------------------------------------------------------------------"
    fi
    echo "Total usage: $size bytes"
}


USAGE="usage: $0 -l -r <file> -d -t -m -k"

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

((pos = OPTIND - 1))
shift $pos

PS3='option> '


if (( $# > 0 ))
then
    backup_files "$@"
else
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

