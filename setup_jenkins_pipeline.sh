#!/bin/bash

# ==============================================================================
# Configuration Variables
# ==============================================================================
# Source Jenkins credentials from external config file
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$DIR/config.env" ]; then
  source "$DIR/config.env"
else
  echo "❌ Error: config.env file not found!"
  exit 1
fi

# Folder configuration
FOLDER_NAME="Instanode"

# Credentials configuration
CRED_ID="Instanode-Github-Happys-Access-token"
CRED_DESC="Git Credentials for Multibranch Pipeline"
CRED_USER="my_git_user"
CRED_PASS="my_git_password"

# Multibranch Pipeline configuration
MULTIBRANCH_NAME="backend-instanode-monitoring-multibranch"
GIT_REPO_URL="https://github.com/Instanodes-Official/node-monitoring-service.git"

# ==============================================================================
# 1. Check & Create Folder
# ==============================================================================
echo "Checking if folder '$FOLDER_NAME' exists..."
FOLDER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u "$USERNAME:$TOKEN" "$JENKINS_URL/job/$FOLDER_NAME/api/json")

if [ "$FOLDER_STATUS" -eq 200 ]; then
  echo "✅ Folder '$FOLDER_NAME' already exists."
else
  echo "⏳ Creating folder '$FOLDER_NAME'..."
  CREATE_FOLDER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$JENKINS_URL/createItem?name=$FOLDER_NAME&mode=com.cloudbees.hudson.plugins.folder.Folder&from=" -u "$USERNAME:$TOKEN" -H "Content-Type: application/x-www-form-urlencoded")
  if [[ "$CREATE_FOLDER_STATUS" =~ ^(200|201|302)$ ]]; then
    echo "✅ Folder '$FOLDER_NAME' created successfully."
  else
    echo "❌ Failed to create folder. HTTP Status: $CREATE_FOLDER_STATUS"
    exit 1
  fi
fi

# ==============================================================================
# 2. Check & Create Credentials
# ==============================================================================
echo -e "\nChecking if credential '$CRED_ID' exists..."
CRED_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u "$USERNAME:$TOKEN" "$JENKINS_URL/credentials/store/system/domain/_/credential/$CRED_ID/api/json")

if [ "$CRED_STATUS" -eq 200 ]; then
  echo "✅ Credential '$CRED_ID' already exists."
else
  echo "⏳ Creating credential '$CRED_ID'..."
  cat <<EOF > temp_cred.xml
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl plugin="credentials">
  <scope>GLOBAL</scope>
  <id>${CRED_ID}</id>
  <description>${CRED_DESC}</description>
  <username>${CRED_USER}</username>
  <password>${CRED_PASS}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

  CREATE_CRED_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" -u "$USERNAME:$TOKEN" -H "Content-Type: application/xml" --data-binary "@temp_cred.xml")
  rm temp_cred.xml
  
  if [[ "$CREATE_CRED_STATUS" =~ ^(200|201|302)$ ]]; then
    echo "✅ Credential '$CRED_ID' created successfully."
  else
    echo "❌ Failed to create credential. HTTP Status: $CREATE_CRED_STATUS"
    exit 1
  fi
fi

# ==============================================================================
# 3. Check & Create Multibranch Pipeline
# ==============================================================================
echo -e "\nChecking if Multibranch Pipeline '$MULTIBRANCH_NAME' exists..."
MB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u "$USERNAME:$TOKEN" "$JENKINS_URL/job/$FOLDER_NAME/job/$MULTIBRANCH_NAME/api/json")

if [ "$MB_STATUS" -eq 200 ]; then
  echo "✅ Multibranch Pipeline '$MULTIBRANCH_NAME' already exists inside '$FOLDER_NAME'."
else
  echo "⏳ Creating Multibranch Pipeline '$MULTIBRANCH_NAME'..."
  cat <<EOF > temp_mb.xml
<?xml version='1.1' encoding='UTF-8'?>
<org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject plugin="workflow-multibranch">
  <actions/>
  <description></description>
  <properties/>
  <folderViews class="jenkins.branch.MultiBranchProjectViewHolder" plugin="branch-api">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </folderViews>
  <healthMetrics/>
  <icon class="jenkins.branch.MetadataActionFolderIcon" plugin="branch-api">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </icon>
  <orphanedItemStrategy class="com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy" plugin="cloudbees-folder">
    <pruneDeadBranches>true</pruneDeadBranches>
    <daysToKeep>-1</daysToKeep>
    <numToKeep>-1</numToKeep>
  </orphanedItemStrategy>
  <triggers>
    <com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger plugin="cloudbees-folder">
      <spec>* * * * *</spec>
      <interval>60000</interval>
    </com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
  </triggers>
  <disabled>false</disabled>
  <sources class="jenkins.branch.MultiBranchProject\$BranchSourceList" plugin="branch-api">
    <data>
      <jenkins.branch.BranchSource>
        <source class="jenkins.plugins.git.GitSCMSource" plugin="git">
          <id>auto-generated-uuid-12345</id>
          <remote>${GIT_REPO_URL}</remote>
          <credentialsId>${CRED_ID}</credentialsId>
          <traits>
            <jenkins.plugins.git.traits.BranchDiscoveryTrait/>
            <jenkins.scm.impl.trait.RegexSCMHeadFilterTrait plugin="scm-api">
              <regex>.*</regex>
            </jenkins.scm.impl.trait.RegexSCMHeadFilterTrait>
          </traits>
        </source>
        <strategy class="jenkins.branch.DefaultBranchPropertyStrategy">
          <properties class="empty-list"/>
        </strategy>
      </jenkins.branch.BranchSource>
    </data>
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </sources>
  <factory class="org.jenkinsci.plugins.workflow.multibranch.WorkflowBranchProjectFactory">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
    <scriptPath>Jenkinsfile</scriptPath>
  </factory>
</org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject>
EOF

  CREATE_MB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$JENKINS_URL/job/$FOLDER_NAME/createItem?name=$MULTIBRANCH_NAME" -u "$USERNAME:$TOKEN" -H "Content-Type: application/xml" --data-binary "@temp_mb.xml")
  rm temp_mb.xml
  
  if [[ "$CREATE_MB_STATUS" =~ ^(200|201|302)$ ]]; then
    echo "✅ Multibranch Pipeline '$MULTIBRANCH_NAME' created successfully!"
  else
    echo "❌ Failed to create Multibranch Pipeline. HTTP Status: $CREATE_MB_STATUS"
    exit 1
  fi
fi

echo -e "\n🎉 All Done! Folder, Credentials, and Multibranch Pipeline are ready to go."
