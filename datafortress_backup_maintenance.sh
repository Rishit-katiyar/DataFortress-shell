#!/bin/bash

# Configuration
SOURCE_DIRS=(
    "/path/to/source/dir1"
    "/path/to/source/dir2"
    "/path/to/source/dir3"
)
BACKUP_DIR="/path/to/backup"
LOG_DIR="/path/to/log"
LOG_FILE="$LOG_DIR/backup.log"
ERROR_LOG_FILE="$LOG_DIR/error.log"
GPG_RECIPIENT="recipient@example.com"
INCREMENTAL_BACKUP_DIR="$BACKUP_DIR/incremental"
INCREMENTAL_LOG_FILE="$LOG_DIR/incremental_backup.log"
MAIL_RECIPIENT="admin@example.com"
MAIL_SUBJECT="Backup Report"
NUM_PROCS=$(nproc)  # Number of processor cores for parallel processing

# Function to perform full backup and encryption
perform_full_backup() {
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    backup_file="$BACKUP_DIR/backup_$timestamp.tar.gz"
    
    # Perform full backup
    tar -czf "$backup_file" "${SOURCE_DIRS[@]}" 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Full backup failed" >> "$LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Full backup failed. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi

    # Encrypt backup
    gpg --recipient "$GPG_RECIPIENT" --encrypt "$backup_file" 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Encryption failed for full backup" >> "$LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Encryption failed for full backup. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Full backup and encryption successful: $backup_file.gpg" >> "$LOG_FILE"
}

# Function to perform incremental backup
perform_incremental_backup() {
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    incremental_backup_dir="$INCREMENTAL_BACKUP_DIR/incremental_$timestamp"
    
    # Perform incremental backup using parallel processing
    parallel -j "$NUM_PROCS" --progress "rsync -a --link-dest='$INCREMENTAL_BACKUP_DIR/latest' {} $incremental_backup_dir" ::: "${SOURCE_DIRS[@]}" 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Incremental backup failed" >> "$INCREMENTAL_LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Incremental backup failed. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi
    
    # Update latest link
    ln -sfn "$incremental_backup_dir" "$INCREMENTAL_BACKUP_DIR/latest"
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Incremental backup successful: $incremental_backup_dir" >> "$INCREMENTAL_LOG_FILE"
}

# Function to perform database backup
perform_database_backup() {
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    db_backup_dir="$BACKUP_DIR/db_backup_$timestamp"
    
    # Backup MySQL databases
    mysqldump -u <username> -p<password> --all-databases > "$db_backup_dir/mysql_backup.sql" 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - MySQL backup failed" >> "$LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - MySQL backup failed. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi
    
    # Compress database backup
    tar -czf "$db_backup_dir.tar.gz" "$db_backup_dir" 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Database backup compression failed" >> "$LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Database backup compression failed. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Database backup successful: $db_backup_dir.tar.gz" >> "$LOG_FILE"
}

# Function to perform file system check and repair
perform_fs_check_and_repair() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Performing file system check and repair..." >> "$LOG_FILE"
    fsck -y /dev/sda1 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - File system check and repair failed" >> "$LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - File system check and repair failed. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi
    echo "$(date +"%Y-%m-%d %H:%M:%S") - File system check and repair successful" >> "$LOG_FILE"
}

# Function to perform system update
perform_system_update() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Performing system update..." >> "$LOG_FILE"
    apt-get update && apt-get upgrade -y 2>> "$ERROR_LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - System update failed" >> "$LOG_FILE"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - System update failed. Please check error logs." | mail -s "$MAIL_SUBJECT" "$MAIL_RECIPIENT"
        exit 1
    fi
    echo "$(date +"%Y-%m-%d %H:%M:%S") - System update successful" >> "$LOG_FILE"
}

# Create backup directories if not exists
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$INCREMENTAL_BACKUP_DIR"

# Perform backups and system maintenance tasks
if [ ! -f "$INCREMENTAL_BACKUP_DIR/latest" ]; then
    perform_full_backup
else
    perform_incremental_backup
fi

perform_database_backup
perform_fs_check_and_repair
perform_system_update

# All tasks completed successfully
echo "$(date +"%Y-%m-%d %H:%M:%S") - All tasks completed successfully" >> "$LOG_FILE"
