# Nextwork AWS VPC

This project contains configurations and scripts for setting up an AWS Virtual Private Cloud (VPC) using Terraform. It aims to provide a robust, secure, and scalable network infrastructure for deploying applications on AWS.

## Table of Contents

- [Nextwork AWS VPC](#nextwork-aws-vpc)
  - [Table of Contents](#table-of-contents)
  - [Project Overview](#project-overview)
  - [Features](#features)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Configuration](#configuration)
    - [Deployment](#deployment)
  - [Project Structure](#project-structure)
  - [Diagram](#diagram)
  - [Contributing](#contributing)
  - [License](#license)

## Project Overview

The Nextwork AWS VPC project is designed to automate the provisioning of a secure and isolated network environment within AWS. This setup is foundational for hosting various applications, ensuring proper network segmentation, routing, and security controls.

## Features

- **Customizable VPC:** Easily define CIDR blocks, subnets (public and private), and availability zones.
- **Internet Gateway:** Provides internet connectivity for resources in public subnets.
- **NAT Gateway:** Enables instances in private subnets to connect to the internet for updates and patches without exposing them directly.
- **Route Tables:** Configured for proper traffic routing between subnets and to/from the internet.
- **Security Groups:** Basic security group configurations to control inbound and outbound traffic.
- **Terraform:** Infrastructure as Code (IaC) for repeatable and version-controlled deployments.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or higher)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- An AWS account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/nextwork-aws-vpc.git
   cd nextwork-aws-vpc
   ```

### Configuration

1. Navigate to the `launch-ec2-instance` directory:
   ```bash
   cd launch-ec2-instance
   ```
2. Review and modify the `variables.tf` file to customize your VPC settings (e.g., `vpc_cidr_block`, `public_subnet_cidrs`, `private_subnet_cidrs`).

### Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Plan the deployment (review changes before applying):
   ```bash
   terraform plan
   ```
3. Apply the changes to create the VPC:
   ```bash
   terraform apply
   ```
   Type `yes` when prompted to confirm.

## Project Structure

```
.
├── .gitignore
├── README.md
├── launch-ec2-instance/
│   ├── main.tf
│   ├── README.md
│   └── variables.tf
└── ...
```

## Diagram

A high-level diagram of the AWS VPC architecture:

```mermaid
graph TD
    A[Internet] --> B(Internet Gateway);
    B --> C{Public Subnet};
    C --> D[EC2 Instance (Public)];
    C --> E(NAT Gateway);
    E --> F{Private Subnet};
    F --> G[EC2 Instance (Private)];
    F --> H[Database (Private)];
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

This project is licensed under the MIT License - see the LICENSE file for details.