# Zabbix SaaS Solution on AWS Cloud

Implementing a Zabbix SaaS solution on the AWS cloud offers diverse possibilities:

1. **Resilient Architecture based on AWS Auto Scaling Group with Application Load Balancer:**
   - Utilizes a resilient architecture employing AWS Auto Scaling Group (ASG) with an Application Load Balancer (ALB).
   - Incorporates a custom Amazon Machine Image (AMI) along with EC2 instances and RDS services.

2. **AWS ECS/Fargate Service with Dockerized Zabbix Application:**
   - Implements the solution using AWS ECS/Fargate service for a Dockerized Zabbix application.

This Proof of Concept (POC) specifically demonstrates the first case, leveraging AWS ASG, ALB, EC2, and RDS services.

## Technical Architecture

### Resilient Architecture (ASG, ALB, EC2, RDS)

- Multiple EC2 instances run Zabbix Server and Zabbix Web components within an Auto Scaling Group.
- EC2 images are stateless and utilize AWS RDS service with a MySQL engine.
- An Application Load Balancer serves as a high-availability cluster, forwarding traffic to all EC2 instances.
- Autoscaling group rules, covered in Terraform example code, define scale-out/in based on busy hours or instance CPU usage.
- Similar scale in/out logic can be implemented for RDS, allowing the use of multiple Availability Zones and instance counts.
- Shared data considerations include using AWS Elastic File System (EFS), which can be shared among stateless EC2 instances (not covered in this POC). EFS facilitates sharing common configurations, storing files, or PHP session files. For PHP session storage, AWS ElastiCache or RDS are recommended.

## Technical Implementation

### Steps for Technical Implementation

1. **Custom AWS AMI Creation:**
   - Create a custom AWS AMI image containing a web server(Apache, Nginx), PHP, Zabbix Server, and Zabbix Web components (excluding the database). Consider creating separate AMIs for Zabbix Server and Zabbix Web for production readiness.
   - Utilize Vagrant and Ansible for local testing and provision.

1.1 **Ansible Playbook Setup:**
   - Use community Galaxy roles like [community.zabbix](https://github.com/ansible-collections/community.zabbix) for Ansible playbook setup. These roles allow installing and using only the required components.

1.2 **Create AMI Image:**
   - Choose from various approaches, such as using Terraform with EC2 provision and running Ansible scripts, using AWS Image Builder, or using Packer. The POC utilizes Packer and Ansible for AMI creation, with code examples available in the 'ami-builder' directory.

1.3 **Infrastructure Creation with Terraform:**
   - Once the AMI image is ready, proceed to create the infrastructure using Terraform. The Terraform project structure is available in the 'infrastructure' folder.

1.4 **Terraform Project Modules:**
   - The Terraform project is organized into multiple environments (e.g., stage, prod) for testing. It follows a modular approach with modules for ASG, ALB, networking, security (using roles and permissions), and RDS. Modules utilize input/output variables and can be easily customized and expanded.

1.5 **Zero Downtime Deployment with Terraform:**
   - Achieve zero downtime deployment using ASG new launch configurations with the following strategy in the Terraform project:
     ```hcl
     instance_refresh {
       strategy = "Rolling"
       preferences {
         min_healthy_percentage = 30
       }
     }
     ```

## Project To-Do List

1. **PHP Session Sharing:**
   - Implement and test PHP session sharing using a sticky session. Options include using ElastiCache, EFS, or RDS for global session storage.

2. **EC2 Instance Provisioning:**
   - Implement EC2 instance provisioning with custom user scripts using shared configuration (possible with S3 or EFS). Define RDS endpoints for new instances.

3. **Lambda Function for Database Backups:**
   - Implement a Lambda function in Python for custom database backups to S3, as the default backup from RDS may not be sufficiently elastic for specific use cases.

4. **Handling CloudWatch Events, SNS, and Subscriptions:**
   - Implement logic for handling CloudWatch events, SNS, and subscriptions, triggering actions such as sending emails.

5. **SSL Encryption with AWS ACM:**
   - Utilize AWS Certificate Manager (ACM) to enable SSL on the ALB. The ALB ensures SSL termination, routing non-SSL traffic to EC2 instances.

6. **Production-Ready Configuration:**
   - Consider having separate ASGs for Zabbix Server and Zabbix Web for production. This may lead to having two ALBs with endpoints.

7. **RDS Instance Placement in Private Subnet:**
   - Move the RDS instance to a private subnet for enhanced security. Ensure routing and route table configurations, allowing traffic from ASG. Private traffic is often more cost-effective.

8. **CI/CD Implementation:**
   - Implement CI/CD using platforms like GitLab. Define steps for creating a new AMI and deploying the new AMI into cluster with zero downtime deployment.