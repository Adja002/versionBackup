# versionBackup

## Overview

**versionBackup** is a powerful and flexible bash script utility that simplifies creating backups for your files while maintaining a version history. Originally developed as a coursework project, this script is designed to run on Linux Mint 17.3 64-bit with bash version 4.3 and automates the backup process by generating a dedicated backup directory, `~/.versionBackup`, if it doesn't already exist.

### Key Features

- **Automated Backup**: With **versionBackup**, you can effortlessly create backups of your important files, ensuring that no data is lost due to accidental modifications or deletions.

- **Version Tracking**: The script appends version numbers to the filenames, allowing you to keep track of the history of each file. For example, a file named `myfile.txt` will become `myfile.txt.1`, and subsequent backups will increment the version number as `myfile.txt.2`, `myfile.txt.3`, and so on.

- **Command Line and Menu Options**: **versionBackup** provides a versatile user experience, offering command line options and a user-friendly menu. Whether you prefer command-line efficiency or a menu-driven interface, the functionality remains consistent.

#### Command Line Options

- `-l`: List the contents of the versionBackup directory.
- `-r file`: Recover a specific file from the versionBackup directory and place it in the current directory.
- `-d`: Interactively delete the contents of the versionBackup directory.
- `-t`: Display the total usage in bytes of the versionBackup directory.
- `-m`: Initiate the monitor script process.
- `-k`: Terminate the current user's monitor script processes.

#### Menu Driven Interface

If you're not a fan of command line arguments, running `versionBackup.sh` without options will display an interactive menu, allowing you to perform the same tasks with ease.

- **Robustness**: This script has been developed with robustness in mind. It performs extensive checks to ensure the validity of the operations, including file existence, readability, and proper file types.

- **Trap Mechanism**: A built-in trap mechanism responds to `SIGINT` signals, providing information on the total number of regular files in your versionBackup directory and gracefully terminating the script.

- **Disk Usage Warning**: For your convenience, **versionBackup** issues a warning message if the disk usage in the versionBackup directory exceeds 1Kbytes. This feature is particularly useful during testing.

- **Monitor Script Enhancement**: The script includes a separate monitor script that runs as a separate process with the `-m` option. This monitor script actively tracks the creation, modification, and deletion of ordinary files in your versionBackup directory, updating you on changes every 15 seconds.

**versionBackup** empowers you to manage your file backups efficiently while maintaining version history, ensuring the safety of your important data.

## Contributing

To improve **versionBackup** or to report and fix any bugs you may encounter. If you have suggestions for enhancements or encounter issues, please consider contributing to this project. Here's how you can get involved:

- [Report a Bug](#) - If you discover a bug, please open an issue with detailed information about the problem.
- [Request a Feature](#) - If you have ideas for new features, feel free to create a feature request issue.
- Fork the repository, make your changes, and submit a pull request.
