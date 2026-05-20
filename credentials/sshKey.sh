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
CRED_ID="my-ssh-key-id"
CRED_DESC="My SSH Key"
CRED_USER="git"
CRED_PASSPHRASE=""
# Leave the multi-line formatting exactly as is for the private key
CRED_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA...
-----END RSA PRIVATE KEY-----"

CREDENTIALS_API_URL="$JENKINS_URL/credentials/store/system/domain/_/createCredentials"

cat <<EOF > ssh_key.xml
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials">
  <scope>GLOBAL</scope>
  <id>${CRED_ID}</id>
  <description>${CRED_DESC}</description>
  <username>${CRED_USER}</username>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>${CRED_PRIVATE_KEY}</privateKey>
  </privateKeySource>
  <passphrase>${CRED_PASSPHRASE}</passphrase>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF

curl -s -X POST "$CREDENTIALS_API_URL" \
     -u "$USERNAME:$TOKEN" \
     -H "Content-Type: application/xml" \
     --data-binary "@ssh_key.xml"

rm ssh_key.xml
echo "Done"
