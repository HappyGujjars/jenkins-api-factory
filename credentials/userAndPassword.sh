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
CRED_ID="my-user-pass"
CRED_DESC="My Username and Password"
CRED_USER="my_user"
CRED_PASS="my_password"

CREDENTIALS_API_URL="$JENKINS_URL/credentials/store/system/domain/_/createCredentials"

cat <<EOF > user_pass.xml
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials">
  <scope>GLOBAL</scope>
  <id>${CRED_ID}</id>
  <description>${CRED_DESC}</description>
  <username>${CRED_USER}</username>
  <password>${CRED_PASS}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

curl -s -X POST "$CREDENTIALS_API_URL" \
     -u "$USERNAME:$TOKEN" \
     -H "Content-Type: application/xml" \
     --data-binary "@user_pass.xml"

rm user_pass.xml
echo "Done"
