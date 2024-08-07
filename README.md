Here’s a streamlined and revised version of the instructions:

---

# iddotmeiac

## Overview

We will be setting up infrastructure for a Python Flask web application on Google Cloud using Infrastructure as Code (IaC) with Terraform. The application will display "Hello World" and retrieve this message from a Cloud SQL database. Here’s how to get started:

### 1. **Google Cloud Account Setup**

1. **Create a Google Cloud account**:
   - Sign up at [Google Cloud Free Tier](https://cloud.google.com/free/docs/gcp-free-tier).

2. **Install Required Tools**:
   - **Python 3**: Used for developing the web application.
   - **gcloud CLI**: Provides an interface to interact with Google Cloud services.
   - **Terraform**: Used for coding the infrastructure. Install it from [Terraform’s installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

### 2. **Configure Google Cloud Environment**

1. **Create a Billing Account**:
   - Set up a billing account in the [Google Cloud Console](https://console.cloud.google.com/billing).

2. **Setup Your Project Directory**:
   - Create a project directory using VSCode or your preferred editor.

### 3. **Infrastructure Code**

1. **Project and Database Setup**:
   - Write Terraform code to create a Google Cloud Project, Cloud SQL database, VPC, and enable monitoring for the resources.
   - **gcp-projects** folder: Manages dynamic project creation. Specify the billing account and deployment region in this setup.
   - Import the `gcp-projects` module into `main.tf` to manage project creation dynamically. Configure project details using `variables.tf`.

2. **Database Configuration**:
   - Set up a Cloud SQL database (MySQL 5.7) with a private IP.
   - Define database credentials and permissions in `cloudsql.tf`.
   - Create secrets for DB credentials (host, username, password, database name) in `main.tf`.

3. **Network Setup**:
   - Define the VPC, including firewall rules, network/subnetwork configuration, and router details in `networking.tf`.

4. **Load Balancer Configuration**:
   - Create an Application Load Balancer in `lb.tf` to distribute traffic using round-robin by default. Configure it to listen on port 80 for the Flask app.

5. **Compute Engine Setup**:
   - Use a Google Compute Engine (GCE) instance template for the virtual machine hosting the Flask app.
   - Specify machine type, disk details (e.g., disk size), and the startup script in your Terraform configuration.
   - **Startup Script**: Located in `scripts/startup.sh`. This script installs necessary software, fetches the Python application from [GitHub](https://github.com/sonamawachar0110/iddotmepython.git), sets up Python environment variables, retrieves secrets from Google Secret Manager, and configures the app.

### 4. **Python Flask Application**

- **Develop the Flask App**:
  - Ensure the app is capable of connecting to the Cloud SQL database and displaying "Hello World" fetched from the database.

### 5. **Automation and Best Practices**

1. **Dynamic Region Selection**:
   - Set the deployment region dynamically in your Terraform configuration instead of hardcoding it.

2. **Billing Account Management**:
   - Automate billing account creation with Terraform instead of using the Google Cloud Console.

3. **Use Terraform Modules**:
   - Modularize your Terraform code for better management and reusability.

4. **Secret Management**:
   - Create and manage secrets separately in a `secret.tf` file using Google Secret Manager.

---

This approach ensures a structured setup of the infrastructure and application deployment on Google Cloud, leveraging best practices for automation and configuration management.
