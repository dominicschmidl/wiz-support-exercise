#!/bin/bash

# Configuration
BUCKET_NAME="wiz-mongo-backups-bucket"
OUTPUT_FILE="index.html"
REGION="us-east-1"
LOGO_URL="https://cdn.brandfetch.io/idXbhQWKqT/theme/light/logo.svg?c=1dxbfHSJFAPEGdCLU4o5B"

# Determine correct numfmt command
if command -v numfmt &> /dev/null; then
    FORMAT_CMD="numfmt --to=iec --suffix=B"
elif command -v gnumfmt &> /dev/null; then
    FORMAT_CMD="gnumfmt --to=iec --suffix=B"
else
    echo "Warning: numfmt not found, showing raw byte sizes."
    FORMAT_CMD="cat"
fi

# Start HTML with modern styling and custom logo
cat <<EOL > $OUTPUT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>MongoDB Backups</title>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Roboto', sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }
    header { background-color: #0073e6; color: #fff; padding: 20px; text-align: center; }
    header img { max-height: 60px; vertical-align: middle; margin-right: 10px; }
    header h1 { display: inline-block; margin: 0; vertical-align: middle; }
    .container { background-color: #fff; padding: 20px; margin: 20px auto; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 800px; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
    a { text-decoration: none; color: #0073e6; font-weight: bold; }
    a:hover { text-decoration: underline; }
    footer { text-align: center; font-size: 0.9em; color: #666; margin: 20px 0; }
    @media (max-width: 600px) {
      .container { margin: 10px; padding: 10px; }
      header img { max-height: 40px; }
      header h1 { font-size: 1.2em; }
    }
  </style>
</head>
<body>
  <header>
    <img src="$LOGO_URL" alt="Logo">
    <h1>MongoDB Backup Files</h1>
  </header>
  <div class="container">
    <table>
      <tr><th>Filename</th><th>Size</th><th>Last Modified</th></tr>
EOL

# List S3 files excluding index.html and add details
aws s3api list-objects-v2 --bucket $BUCKET_NAME --region $REGION --query "Contents[?Key!='index.html']" --output json |
jq -r '.[] | [.Key, (.Size|tostring), .LastModified] | @tsv' |
while IFS=$'\t' read -r key size last_modified; do
    if [ -n "$key" ]; then
        human_size=$($FORMAT_CMD <<< "$size" 2>/dev/null || echo "${size} B")
        echo "      <tr><td><a href=\"https://$BUCKET_NAME.s3.amazonaws.com/$key\">$key</a></td><td>${human_size}</td><td>${last_modified%%T*}</td></tr>" >> $OUTPUT_FILE
    fi
done

# Close HTML
cat <<EOL >> $OUTPUT_FILE
    </table>
    <footer>&copy; $(date +%Y) Dominic Schmidl. All rights reserved.</footer>
  </div>
</body>
</html>
EOL

echo "index.html generated with your custom logo and professional styling."

