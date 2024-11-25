# Google Cloud CLI Installation on Ubuntu

This guide will help you install and configure the **Google Cloud CLI (gcloud)** on Ubuntu.

## Step 1: Update the Package List

Ensure your system packages are up-to-date:

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
sudo apt install -y google-cloud-cli
gcloud version
gcloud init


