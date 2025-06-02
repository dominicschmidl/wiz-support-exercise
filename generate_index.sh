#!/bin/bash

# Variables
BUCKET_NAME="wiz-mongo-backups-bucket"
OUTPUT_FILE="index.html"
REGION="us-east-1"

# Start the HTML file
echo "<!DOCTYPE html>" > $OUTPUT_FILE
echo "<html>" >> $OUTPUT_FILE
echo "<head><title>MongoDB Backups</title></head>" >> $OUTPUT_FILE
echo "<body><h1>Available Backups</h1><ul>" >> $OUTPUT_FILE

# List all objects in the S3 bucket and generate links
aws s3 ls s3://$BUCKET_NAME/ --region $REGION | awk '{print $4}' | while read file; do
    if [ -n "$file" ]; then
        echo "<li><a href=\"https://$BUCKET_NAME.s3.amazonaws.com/$file\">$file</a></li>" >> $OUTPUT_FILE
    fi
done

# Close the HTML file
echo "</ul></body></html>" >> $OUTPUT_FILE

echo "index.html has been generated."

