#!/bin/bash

# vars
BACKUP_DIR="/home/ubuntu/database_backup"
ODOO_DATABASE="your_db_name"
ADMIN_PASSWORD="your_password"

# Remote server details
REMOTE_USER="odoo"
REMOTE_IP="your_ip"
REMOTE_BACKUP_DIR="your_backup_path"

# Log file
LOG_FILE="/home/ubuntu/script/db_backup.log"

# Redirect stdout and stderr to the log file
exec > >(tee -a ${LOG_FILE} )
exec 2>&1

# Create a backup directory
mkdir -p ${BACKUP_DIR}

# Create a backup
curl -X POST \
    -F "master_pwd=${ADMIN_PASSWORD}" \
    -F "name=${ODOO_DATABASE}" \
    -F "backup_format=zip" \
    -o ${BACKUP_DIR}/${ODOO_DATABASE}.$(date +%F).zip \
    http://127.0.0.1:8069/web/database/backup

# Check if the backup was successful
if [ $? -eq 0 ]; then
    # Transfer the backup to the remote server
    echo "Transferring backup to remote server..."
    sshpass -p 'your_password' scp -r -P 22222 ${BACKUP_DIR}/${ODOO_DATABASE}.$(date +%F).zip ${REMOTE_USER}@${REMOTE_IP}:${REMOTE_BACKUP_DIR}

    echo "Backup transferred successfully."
else
    echo "Backup failed. Please check the Odoo backup command and try again."
fi

# Delete old backups (older than 15 days)
find ${BACKUP_DIR} -type f -mtime +15 -name "${ODOO_DATABASE}.*.zip" -exec rm {} \;

echo "Old backups deleted."

