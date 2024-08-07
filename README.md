# Hello World Python Flask App Setup Guide

This guide will help you set up a Python Flask web application on Google Cloud using Infrastructure as Code (IaC) with Terraform. The application will display "Hello World," which it fetches from a Cloud SQL database. Follow these steps to get started, even if you're new to these tools.

## Overview

You will:

1. Create and configure a Google Cloud account.
2. Set up necessary tools and create a project directory.
3. Write and apply Terraform code to set up the infrastructure.
4. Deploy and test the Flask application.

## 1. Google Cloud Account Setup

### Create a Google Cloud Account

- Go to [Google Cloud Free Tier](https://cloud.google.com/free/docs/gcp-free-tier) and sign up for a Google Cloud account.

### Install Required Tools

- **Python 3**: Required for developing the web application. Install it from [Python’s official site](https://www.python.org/).

- **gcloud CLI**: This command-line tool lets you interact with Google Cloud services. Install it by following [Google Cloud SDK Installation](https://cloud.google.com/sdk/docs/install).

- **Terraform**: Used for defining and managing infrastructure as code. Install it from [Terraform’s installation guide](https://developer.hashicorp.com/terraform/docs/cli-config).

## 2. Configure Google Cloud Environment

### Create a Billing Account

- Go to [Google Cloud Console](https://console.cloud.google.com/billing) and set up a billing account.

### Set Up Your Project Directory

- Create a new project directory using VSCode or any code editor of your choice.

## 3. Infrastructure Code

### Project and Database Setup

- **Write Terraform Code**: This code will create the necessary Google Cloud resources. Here's a basic overview of the Terraform files you’ll need:

  - **gcp-projects** folder: Manages dynamic project creation. You'll need to specify your billing account and deployment region here.
  - **main.tf**: Imports the `gcp-projects` module and sets up the project details.

    ```hcl
    module "gcp-projects" {
      source = "./gcp-projects"
      billing_account = var.billing_account
      region           = var.region
    }
    ```

  - **variables.tf**: Contains configuration details such as billing account and deployment region.

    ```hcl
    variable "billing_account" {}
    variable "region" {}
    ```

### Database Configuration

- **Set Up Cloud SQL**: Use Terraform to create a MySQL 5.7 database with a private IP address.

  - **cloudsql.tf**: Defines the database and its credentials.

    ```hcl
    resource "google_sql_database_instance" "my_instance" {
      name             = "my-instance"
      database_version = "MYSQL_5_7"
      region           = var.region

      settings {
        tier = "db-f1-micro"
      }
    }

    resource "google_sql_database" "my_database" {
      name     = "my_database"
      instance = google_sql_database_instance.my_instance.name
    }
    ```

  - **main.tf**: Store DB credentials as secrets.

    ```hcl
    resource "google_secret_manager_secret" "db_credentials" {
      secret_id = "db-credentials"
    }
    ```

### Network Setup

- **Configure VPC**: Define firewall rules, network, subnetwork, and router settings.

  - **networking.tf**: Sets up network-related configurations.

    ```hcl
    resource "google_compute_network" "default" {
      name = "default-network"
    }

    resource "google_compute_firewall" "default" {
      name    = "default-firewall"
      network = google_compute_network.default.name
      allow {
        protocol = "tcp"
        ports    = ["80"]
      }
    }
    ```

### Load Balancer Configuration

- **Set Up Load Balancer**: Distribute traffic to the Flask app.

  - **lb.tf**: Creates an Application Load Balancer.

    ```hcl
    resource "google_compute_global_forwarding_rule" "default" {
      name        = "default-forwarding-rule"
      target      = google_compute_target_http_proxy.default.self_link
      port_range  = "80"
    }
    ```

### Compute Engine Setup

- **Configure GCE Instance**: Use a template for hosting the Flask app.

  - **main.tf**: Define instance type, disk details, and the startup script.

    ```hcl
    resource "google_compute_instance_template" "default" {
      name         = "flask-app-template"
      machine_type = "n1-standard-1"
      disk {
        auto_delete = true
        boot        = true
        source_image = "projects/debian-cloud/global/images/family/debian-10"
      }
      metadata_startup_script = file("scripts/startup.sh")
    }
    ```

  - **Startup Script**: Located in `scripts/startup.sh`. This script sets up the necessary software and configurations.

    ```bash
    #!/bin/bash
    apt-get update
    apt-get install -y python3-pip python3-venv git

    # Clone app code
    git clone https://github.com/sonamawachar0110/iddotmepython.git /opt/app

    # Set up Python environment
    cd /opt/app
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt

    # Start Flask app
    gunicorn app:app --bind 0.0.0.0:80
    ```

### Monitoring

- **Define Monitoring Metrics**: Track CPU load, memory load, request rate, etc.

  - **monitoring.tf**: Configure monitoring and alerting.

    ```hcl
    resource "google_monitoring_alert_policy" "default" {
      display_name = "CPU Load Alert"
      conditions {
        condition_threshold {
          filter     = "metric.type=\"compute.googleapis.com/instance/diskio/write_bytes_count\""
          comparison = "COMPARISON_GT"
          threshold_value = 1000000
        }
      }
    }
    ```

## 4. Deploying the Flask Application

### Prepare Environment Variables

- **Export Variables**:

    ```bash
    export TF_VAR_org_id=$(gcloud organizations list --format=json | jq -r '.[0].name' | cut -d'/' -f2)
    export TF_VAR_billing_account=$(gcloud beta billing accounts list --format=json | jq -r '.[0].name' | cut -d'/' -f2)
    ```

- **Log in to Google Cloud**:

    ```bash
    gcloud auth application-default login
    ```

### Run Terraform Commands

- **Initialize Terraform**:

    ```bash
    terraform init
    ```

- **Plan and Apply Changes**:

    ```bash
    terraform plan
    terraform apply
    ```

### Access the Application

- **Retrieve IP Address**:

  - Go to Google Cloud -> Network Services -> Load Balancer and get the IP address.

- **View the App**:

  - Paste the IP address into your browser to see the "Hello World" message.

## Conclusion

By following this guide, you will successfully deploy a Python Flask web application on Google Cloud. The application will display a "Hello World" message retrieved from a Cloud SQL database, demonstrating a complete setup from infrastructure provisioning to application deployment. This process leverages Terraform for infrastructure management and integrates various Google Cloud services to ensure a scalable and manageable deployment.

## Automation and Best Practices

### Dynamic Region Selection

- **What It Is:** Configuring deployment regions dynamically in Terraform.
- **Why It’s Important:** Allows you to deploy resources in the most appropriate geographic location for better performance, compliance, and cost efficiency.

### Automate Billing Account Management

- **What It Is:** Using Terraform to automatically create and manage billing accounts.
- **Why It’s Important:** Streamlines financial setup, reduces manual errors, and integrates billing management into your infrastructure code for consistency and ease of use.

### Modularize Terraform Code

- **What It Is:** Using Terraform modules to organize and reuse code.
- **Why It’s Important:** Improves code management, reduces duplication, and simplifies maintenance by encapsulating reusable configurations.

### Manage Secrets

- **What It Is:** Storing secrets securely in `secret.tf` using Google Secret Manager.
- **Why It’s Important:** Enhances security by keeping sensitive information out of code and providing a centralized, secure method for managing secrets.

### Monitoring with Prometheus and Grafana

- **What It Is:** Setting up monitoring tools to track application and infrastructure performance.
- **Why It’s Important:** Provides insights into system health, helps in detecting issues early, and ensures that your services meet performance standards.

### Create SLO/SLA Dashboards

- **What It Is:** Creating dashboards to visualize Service Level Indicators (SLIs) and measure performance against Service Level Objectives (SLOs).
- **Why It’s Important:** Ensures that service performance meets agreed-upon targets and provides transparency to stakeholders.

### Use Artifact Registry

- **What It Is:** Storing Docker images in Google Artifact Registry.
- **Why It’s Important:** Offers secure, centralized storage for artifacts with better integration and security features compared to Google Container Registry.

### Set Up DNS

- **What It Is:** Creating DNS records to manage domain names.
- **Why It’s Important:** Provides user-friendly domain names instead of exposing raw IP addresses, improving accessibility and security.

### Generalize Project Setup

- **What It Is:** Developing scripts for configuring projects across different environments (e.g., dev, test, staging, production).
- **Why It’s Important:** Ensures consistent setup and easier management across multiple environments, supporting scalable and flexible deployments.

## FAQ

**Q: What should I do if I encounter issues during the Terraform apply step?**

- A: Check the error messages carefully. Common issues include incorrect configurations or missing permissions. Ensure that all required variables are correctly set and that your Google Cloud account has the necessary permissions.

**Q: How do I modify the application to display different content?**

- A: Update the content in the Cloud SQL database. The Flask application fetches and displays the message stored in the database. Modify the database entry to change the displayed message.

**Q: Can I use a different database version or type?**

- A: Yes, you can modify the `cloudsql.tf` file to specify a different database version or type. Ensure that any changes are compatible with your application code.

**Q: How do I update the Flask application code?**

- A: Edit the code in the GitHub repository linked in the startup script (`scripts/startup.sh`). Push changes to GitHub, and the application will automatically pull the latest version during the next deployment or update.

**Q: What if I need to scale the application?**

- A: You can adjust the number of workers and threads in the Gunicorn configuration or modify the Compute Engine instance settings to handle increased traffic. Consider using Google Cloud’s autoscaling features for automatic scaling based on demand.

**Q: How do I access the application’s logs?**

- A: Logs can be accessed via the Google Cloud Console under the "Logging" section. You can view and analyze logs to troubleshoot issues or monitor application performance.

**Q: How can I secure my application?**

- A: Use Google Cloud’s security features such as Identity and Access Management (IAM) to control access. Ensure that your secrets and credentials are managed securely using Google Secret Manager. Regularly review and update security configurations as needed.

For more detailed information or additional help, refer to the official [Google Cloud documentation](https://cloud.google.com/docs) or [Terraform documentation](https://developer.hashicorp.com/terraform/docs).
