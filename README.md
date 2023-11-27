# Continuous Integration and Continuous Delivery (CI/CD) on GCP (Project)

### Architecture Diagram
![images](./images/CI-CD-GCP-.drawio.png)

    > DevOps: Plan -> Code -> Build -> Test -> Release -> Deploy -> Operate -> Monitor

---
## GCP Services
![Infrastructure Automation Services GCP](images/infra.drawio.png)

* Custom VPC with three subnets -> App Network
* Static IP Address -> Database Static Ip Address
* Cloud Storage -> Store Startup Script 
* IAM Service Account  -> For Security
* IAM Custom Role -> For Security 
* Compute Engine -> Database Server
* Artifact Registry -> Store Container Image
* Cloud Build -> Build the image and submit to Artifact Registry
* Cloud Run -> Run the App
* Vertex AI Language Model -> Chat Language Model

---
### Using gcloud and shell scripting

#### Prerequisite
* GCP Account
* Project Owner IAM Role

```sh
# Automate the GCP Services Creation
sh infrastructure-automation-gcp.sh

# Clean Up
sh cleanup.sh
```
---
    Project: (# TO DO)
    | Code Source / Source Control Management : GCP Cloud Repositories / GitHub
    | Build and Test: Cloud Build
    | Release: GCP Artifact Registry / GCP Cloud Repositories / GitHub
    | Deploy: GKE / Cloud Run 
    | Monitor: Cloud Operations Suite

---
### Resources
* GitHub Repository: https://github.com/mregojos/CI-CD-GCP
* GitHub Repository Tech Stack for Cloud, DevOps, SRE: https://github.com/mregojos/tech-stack
* Google Cloud Documentation: https://cloud.google.com/docs
* Google Cloud Architecture: https://cloud.google.com/architecture
* Google Cloud Architecture Framework: https://cloud.google.com/architecture/framework
* Google Cloud CI/CD: https://cloud.google.com/ ci-cd
* Google Cloud DevOps: https://cloud.google.com/devops
* Google Cloud Cloud Repositories
* Google Cloud Cloud Build: https://cloud.google.com/build
* Google Cloud Artifact Registry
* Google Cloud Cloud Google Kubernetes Engine (GKE): https://cloud.google.com/kubernetes-engine
* Google Cloud Cloud Run: https://cloud.google.com/run
* Google Cloud Operations Suite

