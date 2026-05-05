# Bootstrapping Procedure (gcloud CLI)

Run these commands on your local machine using an account with Project Creation and Organization Admin (or Billing Admin) privileges.

## 1. Log in to your Google Cloud account
gcloud auth login

## 2. Create the new project
gcloud projects create <YOUR_PROJECT_ID> --name="Flaskr CI-CD"

## 3. Set the new project as your active default configuration
gcloud config set project <YOUR_PROJECT_ID>

## 4. Link the billing account (Find your ID using `gcloud billing accounts list`)
gcloud billing projects link <YOUR_PROJECT_ID> \
    --billing-account=<YOUR_BILLING_ACCOUNT_ID>

## 5. Enable Necessary APIs (Added IAP API)
gcloud services enable \
    compute.googleapis.com \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    iap.googleapis.com

## 6. Create the Firewall Rule for IAP
## GCP's IAP service uses the IP range 35.235.240.0/20 to tunnel TCP traffic.
gcloud compute firewall-rules create allow-ssh-ingress-from-iap \
    --direction=INGRESS \
    --action=allow \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --network=default

## 7. Create the Service Account for GitHub Actions
gcloud iam service-accounts create github-actions-sa \
    --description="GitHub Actions CI/CD pipeline" \
    --display-name="GitHub Actions SA"

## 8. Grant Compute Admin role (to create/destroy VMs)
gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
    --member="serviceAccount:github-actions-sa@<YOUR_PROJECT_ID>.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

## 9. Grant IAP-secured Tunnel User role (for IAP access)
gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
    --member="serviceAccount:github-actions-sa@<YOUR_PROJECT_ID>.iam.gserviceaccount.com" \
    --role="roles/iap.tunnelResourceAccessor"

## 10. Grant Service Account User role (Allows the SA to attach itself to instances)
gcloud projects add-iam-policy-binding <YOUR_PROJECT_ID> \
    --member="serviceAccount:github-actions-sa@<YOUR_PROJECT_ID>.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

## 11. Generate the JSON key file (Upload this to GitHub Secrets as `GCP_CREDENTIALS`)
gcloud iam service-accounts keys create gcp-key.json \
    --iam-account=github-actions-sa@<YOUR_PROJECT_ID>.iam.gserviceaccount.com

# Required GitHub Configurations:

## Secrets: `GCP_CREDENTIALS`, `GEMINI_API_KEY`, `GCP_PROJECT_ID`

## Variables: `REPO_URL`
