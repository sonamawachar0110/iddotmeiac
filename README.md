# iddotmeiac
Creating infrastructure 
Create an google cloud account using https://cloud.google.com/free/docs/gcp-free-tier
Install python3,gcloud and terraform. Python is our choice of language that we will be using for creating web application. Gcloud will give us interface to connect with Google Cloud . Terraform(https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) will be used for coding infrastructure of GCP resources.
Create billing account in Google console.
Create directory under vscode .
Start writing code to create project, create database,create VPC, add monitoring to the GCP resources.
The folder gcp-projects will create project dynamically for us. We need to specify which  billing account we will be using . You can also specify which region you would like this application to be deployed. 
We are importing gcp-projects into main.tf file to create project id for us dynamically, where we are setting the details of project with the help of variables.tf file
Then we are creating the private IP address for hosting our cloudsql database. I am using mysql 5.7 here . We will need to create username and password as google instate does not offer credentials baked in it.
We will need to create database using cloudsql resource and need to grant necessary permissions to the service account to perform actions on database. We are also creating root user and password in cloudsql.tf file
Next we will be creating secrets to store our db credentials such as db host, username , passport and database name under main.tf file.
After this we will need to create VPC where we will be specifying firewall rules, creating network/subnetwork and router details under networking.tf file
To cater large scale growth , we want application to be able to serve growing traffic which is why we will be creating application load balancer which will use round robin by default and balance the traffic for us. The detail of load balancer are written down under lb.tf. we have set port 80 where we will be able to access our python flask app.
The last step will be having GCE instance created for hosting app on virtual machine. I am using GCE instance template down here I am specifying machine type, disk details such as disk_size, the image that the machine will be using . And specifying which startup script this machine should run. 
The startup script located under scripts/startup.sh where we are installing necessary software, fetching details of my python app which is hosted on GitHub over here - ttps://github.com/sonamawachar0110/iddotmepython.git. We are setting up python env variables , then we are fetching the secrets from google secret manager and setting it as env variables. Post which 

Creating python flask app


Automation
Setting region dynamically rather than manually
Creating billing account through terraform and not through console
Use modules instead of resources
Google Secret manager secret creation can be separately under secret.tf file 

 
