#!/bin/bash

# Variables
BACKUP_DIR="/tmp/mongo-backups"
ARCHIVE_FILE="/tmp/mongodb-backup-$(date +%Y%m%d%H%M%S).tgz"
BUCKET_NAME="wiz-mongo-backups-bucket"
MONGO_HOST="10.0.1.229"
MONGO_USER="admin"
MONGO_PASSWORD="pppp"

# Create a backup directory
mkdir -p $BACKUP_DIR

# Dump the MongoDB database
mongodump --host $MONGO_HOST --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin --out $BACKUP_DIR

# Compress the backup into a .tgz file
tar -czvf $ARCHIVE_FILE -C $BACKUP_DIR .

# Upload the .tgz backup to S3
aws s3 cp $ARCHIVE_FILE s3://$BUCKET_NAME/ 

# (Optional) Set bucket policy for public listing (run this once manually)
# aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

# Clean up local backup files
rm -rf $BACKUP_DIR
rm -f $ARCHIVE_FILE

