# Jenkins API Factory

A collection of Bash scripts to automate the creation of Jenkins resources (Folders, Credentials, and Multibranch Pipelines) directly via the Jenkins REST API, completely bypassing the GUI.

## 🚀 How it Works

The scripts interact with your Jenkins instance via its REST API endpoints. Instead of hardcoding credentials in every file, this project uses a centralized `config.env` file. The scripts read your Jenkins URL and Access Token from this config file and perform tasks like:
- Automatically creating a Jenkins Folder.
- Storing various types of credentials securely.
- Provisioning a Multibranch Pipeline linked to a Git repository.

## 📋 Prerequisites

Before running any scripts, ensure you have the following:

1. **Jenkins Server**: A running instance of Jenkins (e.g., `http://localhost:8087`).
2. **Jenkins API Token**: You must generate an API Token for your user.
   - Go to Jenkins GUI -> Top right corner (click your Username) -> Configure -> API Token -> **Add new Token**.
3. **cURL**: Ensure `curl` is installed on your local machine to make the API requests.
4. **Bash Environment**: A Unix-like terminal (Linux/macOS or Git Bash on Windows).

## 🛠️ Setup Instructions

### 1. Configure your Environment

Create a file named `config.env` in the root of this repository. **Do not commit this file to version control (it is securely ignored via `.gitignore`)**.

Add your Jenkins details to `config.env`:

```env
JENKINS_URL="http://localhost:8087"
USERNAME="your_jenkins_username"
TOKEN="your_jenkins_api_token"
```

### 2. Make Scripts Executable

Ensure all scripts have execution permissions. Run this from the root of the repository:

```bash
chmod +x setup_jenkins_pipeline.sh
chmod +x credentials/*.sh
```

## ⚙️ Usage

### The "All-in-One" Pipeline Setup

To set up a complete Jenkins pipeline (Folder + Git Credentials + Multibranch Pipeline) in one go, use the main orchestrator script:

```bash
./setup_jenkins_pipeline.sh
```

**What it does:**
1. Checks if the designated folder exists; creates it if it doesn't.
2. Checks if the required Git credentials exist; creates them if they don't.
3. Checks if the Multibranch Pipeline exists; creates it and points it to your Git repository.

*Note: Open `setup_jenkins_pipeline.sh` to modify the folder names, repository URL, and credential details according to your project needs.*

### Creating Individual Credentials

If you only need to create specific credentials, navigate to the `credentials/` directory:

```bash
cd credentials/
```

We provide standalone scripts for different credential types:
- **`userAndPassword.sh`**: For standard Username/Password auth.
- **`secretText.sh`**: For API tokens, Webhook secrets, etc.
- **`secretFile.sh`**: For uploading files like `kubeconfig` or Keystores (automatically handles Base64 encoding).
- **`sshKey.sh`**: For private SSH keys.

Open the script you need, modify the configuration variables at the top of the file (like `CRED_ID`, `CRED_DESC`, etc.), and execute it:

```bash
./userAndPassword.sh
```
