#!/bin/bash

# Source Jenkins credentials from external config file
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$DIR/config.env" ]; then
  source "$DIR/config.env"
else
  echo "❌ Error: config.env file not found!"
  exit 1
fi

# Credential Details
CRED_ID="my-secret-file-id"
CRED_DESC="My Secret File"
CRED_FILENAME="my_secret_file.txt"
CRED_FILE_CONTENT="This is my secret file content"

CREDENTIALS_API_URL="$JENKINS_URL/credentials/store/system/domain/_/createCredentials"

BASE64_CONTENT=$(echo -n "$CRED_FILE_CONTENT" | base64 | tr -d '\n')

cat <<EOF > secret_file.xml
<org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl plugin="plain-credentials">
  <scope>GLOBAL</scope>
  <id>${CRED_ID}</id>
  <description>${CRED_DESC}</description>
  <fileName>${CRED_FILENAME}</fileName>
  <secretBytes>${BASE64_CONTENT}</secretBytes>
</org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl>
EOF

curl -s -X POST "$CREDENTIALS_API_URL" \
     -u "$USERNAME:$TOKEN" \
     -H "Content-Type: application/xml" \
     --data-binary "@secret_file.xml"

rm secret_file.xml
echo "Done"
