# DataFortress-shell 🛡️

DataFortress-shell is an advanced shell script designed to provide a comprehensive solution for automating data backup, encryption, and system maintenance tasks. With a plethora of features and robust error handling mechanisms, DataFortress-shell ensures the security, reliability, and integrity of your valuable data.

## Features

### Automated Backups
DataFortress-shell offers both full and incremental backup functionalities, allowing users to schedule regular backups of specified directories. Whether it's a single directory or multiple sources, DataFortress-shell handles it all efficiently.

### Encryption
Security is paramount, which is why DataFortress-shell encrypts backup files using GPG (GNU Privacy Guard). With encryption, your sensitive data remains protected even in the event of unauthorized access to backup storage.

### Database Backup
In addition to file backups, DataFortress-shell also supports backing up MySQL databases. With a simple configuration, users can ensure the safety of their database contents alongside regular file backups.

### System Maintenance
DataFortress-shell goes beyond backups, offering system maintenance features such as file system checks, repairs, and system updates. By incorporating these tasks into the backup routine, users can maintain the health and performance of their systems effortlessly.

### Error Handling
Robust error handling is a key aspect of DataFortress-shell. Detailed logging of backup and maintenance activities, along with email notifications for failures, ensures that users stay informed about any issues and can take appropriate action promptly.

## Installation

### Prerequisites
Before installing DataFortress-shell, ensure that you have the following prerequisites:

- Bash shell
- GPG (GNU Privacy Guard) installed
- MySQL client for database backups
- GNU Parallel for parallel processing (optional but recommended for faster incremental backups)

### Installation Steps

1. **Clone the repository:**

```bash
git clone https://github.com/Rishit-katiyar/DataFortress-shell.git
```

2. **Navigate to the DataFortress-shell directory:**

```bash
cd DataFortress-shell
```

3. **Make the script executable:**

```bash
chmod +x datafortress_backup_maintenance.sh
```

## Usage

1. **Configuration:**

Before running DataFortress-shell, it's essential to configure the script according to your requirements. Open the script in a text editor and modify the configuration variables as needed.

```bash
nano datafortress_backup_maintenance.sh
```

2. **Run the script:**

Once configured, execute the script to initiate the backup and maintenance tasks.

```bash
./datafortress_backup_maintenance.sh
```

## Configuration

DataFortress-shell provides extensive configuration options to tailor the backup and maintenance tasks to your specific needs. Below are the key configuration variables:

- **SOURCE_DIRS:** Specify the directories to be backed up.
- **BACKUP_DIR:** Set the backup destination directory.
- **GPG_RECIPIENT:** Specify the GPG recipient for encryption.
- **MAIL_RECIPIENT:** Email address for receiving notifications.
- **NUM_PROCS:** Number of processor cores for parallel processing.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute it according to the terms of the license.

