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
CRED_ID="my-secret-text-id"
CRED_DESC="My Secret Text"
CRED_SECRET="my_secret_token_value"

CREDENTIALS_API_URL="$JENKINS_URL/credentials/store/system/domain/_/createCredentials"

cat <<EOF > secret_text.xml
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl plugin="plain-credentials">
  <scope>GLOBAL</scope>
  <id>${CRED_ID}</id>
  <description>${CRED_DESC}</description>
  <secret>${CRED_SECRET}</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF

curl -s -X POST "$CREDENTIALS_API_URL" \
     -u "$USERNAME:$TOKEN" \
     -H "Content-Type: application/xml" \
     --data-binary "@secret_text.xml"

rm secret_text.xml
echo "Done"
