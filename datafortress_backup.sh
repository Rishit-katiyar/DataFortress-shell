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

# Create backup directories if not exists
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$INCREMENTAL_BACKUP_DIR"

# Perform full backup on first run
if [ ! -f "$INCREMENTAL_BACKUP_DIR/latest" ]; then
    perform_full_backup
else
    perform_incremental_backup
fi
