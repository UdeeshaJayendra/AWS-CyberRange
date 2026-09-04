# AWS CyberRange — Cloud Attack Simulation & Defense Lab

> An authorized AWS-based cybersecurity lab for simulating controlled attacks, collecting security evidence, detecting suspicious activity, applying defensive controls, and validating the results through retesting.

---

## 📌 Overview

**AWS CyberRange** is a hands-on cloud security laboratory built on **Amazon Web Services (AWS)** and provisioned using **Terraform**.

The project demonstrates a complete security testing workflow:

```text
Deploy → Reconnaissance → Attack Simulation → Detection
       → Investigation → Hardening → Retesting
```

Instead of only building secure cloud infrastructure, this project focuses on **simulating attacks against a controlled AWS environment and investigating the resulting evidence**.

All security testing was performed against infrastructure owned and controlled for this lab.

---

## 🎯 Objectives

The main objectives of this project are to:

* Build a controlled cybersecurity environment in AWS
* Provision infrastructure using Infrastructure as Code
* Perform authorized network reconnaissance
* Simulate controlled SSH authentication attacks
* Capture authentication and network activity
* Centralize security logs using Amazon CloudWatch
* Analyze suspicious SSH activity
* Develop a Python-based detection script
* Apply SSH hardening
* Retest the environment after defensive changes
* Document the investigation and results

---

## 🏗️ Architecture

The CyberRange consists of an AWS VPC containing a public subnet and an EC2 target machine.

```text
                         Internet
                            │
                            │
                    Authorized Tester
                            │
                            ▼
                  ┌──────────────────┐
                  │   Internet GW    │
                  └────────┬─────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │     AWS VPC         │
                │    10.50.0.0/16     │
                │                     │
                │  Public Subnet      │
                │  10.50.1.0/24       │
                │                     │
                │  ┌───────────────┐  │
                │  │ EC2 Target    │  │
                │  │ Ubuntu 24.04  │  │
                │  │ Nginx         │  │
                │  │ SSH           │  │
                │  └───────┬───────┘  │
                └──────────┼───────────┘
                           │
              ┌────────────┴─────────────┐
              │                          │
              ▼                          ▼
       CloudWatch Logs            VPC Flow Logs
              │
              ▼
       Security Investigation
              │
              ▼
       Detection & Hardening
```

---

## ☁️ AWS Services Used

| Service                 | Purpose                       |
| ----------------------- | ----------------------------- |
| **Amazon VPC**          | Isolated CyberRange network   |
| **Amazon EC2**          | Controlled attack target      |
| **Internet Gateway**    | Internet connectivity         |
| **Security Groups**     | Network access control        |
| **IAM**                 | AWS permissions and EC2 roles |
| **AWS Systems Manager** | Secure remote administration  |
| **Amazon CloudWatch**   | Centralized security logs     |
| **VPC Flow Logs**       | Network traffic visibility    |
| **Terraform**           | Infrastructure as Code        |

---

## 🔐 Security Design

The lab was designed with security controls while still allowing controlled attack simulation.

### Network Controls

* Dedicated CyberRange VPC
* Public subnet for the controlled target
* Internet Gateway
* Security Group restricting SSH access
* HTTP access available for the web service
* VPC Flow Logs enabled

### SSH Access

SSH access is restricted to the authorized administrator IP address.

```text
SSH (22)
    │
    └── Allowed only from authorized administrator CIDR
```

This allows the SSH attack simulation to be performed from the authorized testing machine while preventing unrestricted SSH exposure.

---

## 🏗️ Infrastructure as Code

The AWS infrastructure is provisioned using **Terraform**.

Terraform manages:

* VPC
* Subnet
* Internet Gateway
* Route Table
* Security Group
* EC2 instance
* IAM roles
* IAM policies
* CloudWatch Log Groups
* VPC Flow Logs
* Systems Manager configuration

### Deployment

```bash
terraform init
terraform plan
terraform apply
```

### Destroy Infrastructure

The environment can be removed after testing:

```bash
terraform destroy
```

This helps prevent unnecessary AWS resource usage and costs.

---

## 🔎 Phase 1 — Network Reconnaissance

After deploying the target, authorized reconnaissance was performed using **Nmap**.

The objective was to identify:

* Open ports
* Available services
* Service versions
* Network exposure

### Nmap Service Scan

```bash
nmap -Pn -sV <TARGET_IP>
```

The scan identified the HTTP service running on port `80`.

Example result:

```text
PORT   STATE SERVICE VERSION
80/tcp open  http    nginx 1.24.0 (Ubuntu)
```

### Screenshot

> 📷 **Screenshot 01 — Nmap Service Scan**
>
> Replace the placeholder below with your actual screenshot.

```text
[SCREENSHOT: docs/screenshots/01-nmap-service-scan.png]
```

---

## 🌐 Phase 2 — HTTP Enumeration

HTTP enumeration was performed against the controlled web server.

Command:

```bash
nmap -Pn -p 80 --script http-title <TARGET_IP>
```

This confirmed that the web service was reachable.

### Screenshot

> 📷 **Screenshot 02 — HTTP Enumeration**

```text
[SCREENSHOT: docs/screenshots/02-http-enumeration.png]
```

---

# 🚨 Phase 3 — Controlled SSH Attack Simulation

A controlled SSH authentication attack was performed against the CyberRange target.

The simulated username was:

```text
fakeuser
```

The purpose was **not to gain unauthorized access**, but to generate realistic authentication events that could be detected and investigated.

Example:

```bash
ssh fakeuser@<TARGET_IP>
```

The server rejected the authentication attempt.

```text
Permission denied (publickey).
```

---

## 📝 Authentication Evidence

The SSH authentication logs recorded suspicious activity in:

```text
/var/log/auth.log
```

Example:

```text
Invalid user fakeuser from ATTACKER_IP port 16611
Connection reset by invalid user fakeuser ATTACKER_IP port 16611 [preauth]

Invalid user fakeuser from ATTACKER_IP port 16614
Connection reset by invalid user fakeuser ATTACKER_IP port 16614 [preauth]
```

These events provide evidence that an invalid SSH account was being used against the target.

### Screenshot

> 📷 **Screenshot 03 — SSH Attack Detection / Authentication Evidence**

```text
[SCREENSHOT: docs/screenshots/03-ssh-detection.png]
```

---

# ☁️ Phase 4 — CloudWatch Log Collection

Security-relevant logs were centralized in **Amazon CloudWatch Logs**.

The following logs were collected:

```text
/var/log/auth.log
/var/log/nginx/access.log
/var/log/nginx/error.log
```

CloudWatch Log Group:

```text
/aws/cyberrange/aws-cyberrange
```

This provides centralized visibility into activity occurring on the EC2 target.

### Screenshot

> 📷 **Screenshot 04 — CloudWatch Security Logs**

```text
[SCREENSHOT: docs/screenshots/04-cloudwatch-logs.png]
```

---

# 🌐 Phase 5 — VPC Flow Logs

VPC Flow Logs were enabled to provide network-level visibility.

Flow Logs capture information such as:

* Source IP
* Destination IP
* Source port
* Destination port
* Protocol
* Traffic direction
* Accept / reject status

This complements host-based authentication logs by providing network-level evidence.

### Screenshot

> 📷 **Screenshot 05 — VPC Flow Logs**

```text
[SCREENSHOT: docs/screenshots/05-vpc-flow-logs.png]
```

---

# 🧠 Phase 6 — SSH Detection Script

A Python detection script was developed to identify suspicious SSH authentication events.

Location:

```text
scripts/detect_ssh.py
```

The script searches for log entries matching:

```text
Invalid user <username> from <source_ip> port <port>
```

When a matching event is found, the script generates an alert containing:

* Username
* Source IP
* Source port
* Total suspicious attempts

Example:

```text
=== SSH Suspicious Activity Detection ===

[ALERT] Invalid SSH user detected
        Username : fakeuser
        Source IP: ATTACKER_IP
        Port     : 16611

[ALERT] Invalid SSH user detected
        Username : fakeuser
        Source IP: ATTACKER_IP
        Port     : 16614

Total suspicious SSH attempts: 2
```

### Screenshot

> 📷 **Screenshot 06 — Python SSH Detection Output**

```text
[SCREENSHOT: docs/screenshots/06-python-detection.png]
```

---

# 🛡️ Phase 7 — SSH Hardening

After identifying the suspicious SSH activity, SSH authentication was hardened.

The following configuration was applied:

```text
PasswordAuthentication no
```

The configuration was stored in:

```text
/etc/ssh/sshd_config.d/99-cyberrange-hardening.conf
```

The SSH configuration was validated before reloading the service.

This ensures that password-based SSH authentication is disabled.

---

# 🔄 Phase 8 — Retesting After Hardening

After applying the defensive control, the same controlled SSH test was performed again.

The target continued to reject the unauthorized account:

```text
Permission denied (publickey).
```

The authentication event was also visible in CloudWatch.

This demonstrates the security testing lifecycle:

```text
Initial Test
     │
     ▼
Detect Suspicious Activity
     │
     ▼
Investigate Evidence
     │
     ▼
Apply SSH Hardening
     │
     ▼
Retest
     │
     ▼
Verify Defensive Control
```

### Screenshot

> 📷 **Screenshot 07 — CloudWatch SSH Detection After Hardening**

```text
[SCREENSHOT: docs/screenshots/07-cloudwatch-ssh-detection-after-hardening.png]
```

---

# 📊 Before vs After

| Security Test                 | Before Hardening            | After Hardening |
| ----------------------------- | --------------------------- | --------------- |
| Invalid SSH username detected | Yes                         | Yes             |
| Unauthorized authentication   | Rejected                    | Rejected        |
| Password authentication       | Available for configuration | Disabled        |
| Authentication logs           | Collected                   | Collected       |
| CloudWatch visibility         | Enabled                     | Enabled         |
| Detection capability          | Python detector             | Python detector |
| Security evidence             | Available                   | Available       |
| Retesting                     | N/A                         | Successful      |

The objective of hardening was not to hide the attack event. Instead, the project demonstrates that suspicious activity can still be **detected, logged, investigated, and controlled**.

---

# 🔍 Investigation Report

The complete investigation is documented in:

```text
reports/ssh-attack-investigation.md
```

The report contains:

* Investigation objective
* Target information
* Attack simulation
* Authentication evidence
* CloudWatch evidence
* Detection results
* SSH hardening
* Retesting results
* Final security assessment

---

# 📸 AWS Infrastructure Evidence

The project also includes screenshots showing the deployed AWS infrastructure.

### AWS VPC

```text
[SCREENSHOT: docs/screenshots/08-aws-vpc-infrastructure.png]
```

### EC2 Target

```text
[SCREENSHOT: docs/screenshots/09-aws-ec2-target.png]
```

### Security Group

```text
[SCREENSHOT: docs/screenshots/10-aws-security-group.png]
```

> **Note:** Keep screenshots free of sensitive credentials, access keys, private keys, or other secrets before publishing the repository.

---

# 📁 Project Structure

```text
AWS-CyberRange/
│
├── .gitignore
│
├── docs/
│   └── screenshots/
│       ├── 01-nmap-service-scan.png
│       ├── 02-http-enumeration.png
│       ├── 03-ssh-detection.png
│       ├── 04-cloudwatch-logs.png
│       ├── 05-vpc-flow-logs.png
│       ├── 06-python-detection.png
│       ├── 07-cloudwatch-ssh-detection-after-hardening.png
│       ├── 08-aws-vpc-infrastructure.png
│       ├── 09-aws-ec2-target.png
│       └── 10-aws-security-group.png
│
├── reports/
│   └── ssh-attack-investigation.md
│
├── scenarios/
│
├── scripts/
│   ├── detect_ssh.py
│   └── ssh_events.log
│
└── terraform/
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    └── .terraform.lock.hcl
```

---

# 🧰 Technologies

### Cloud

* Amazon Web Services
* Amazon EC2
* Amazon VPC
* Amazon CloudWatch
* AWS Systems Manager
* IAM

### Infrastructure

* Terraform
* Infrastructure as Code
* AWS Security Groups
* VPC Flow Logs

### Security

* Nmap
* SSH
* Linux authentication logs
* Security monitoring
* Log analysis
* SSH hardening
* Controlled attack simulation

### Programming

* Python
* Regular Expressions

---

# 🔐 Security & Authorization

This project is intended strictly for **authorized cybersecurity testing and education**.

All reconnaissance, attack simulation, logging, detection, and hardening activities were performed against infrastructure controlled for this CyberRange.

The techniques demonstrated in this repository should only be used against systems where explicit authorization has been granted.

---

# 🚀 Skills Demonstrated

This project demonstrates practical experience in:

* Cloud security
* AWS networking
* Infrastructure as Code
* Terraform
* Linux administration
* Network reconnaissance
* Security monitoring
* Log analysis
* Incident investigation
* SSH security
* CloudWatch
* VPC Flow Logs
* IAM
* AWS Systems Manager
* Python automation
* Security hardening
* Attack detection
* Security validation and retesting

---

10. Document the results
```

This approach provides practical experience with both **offensive security testing and defensive security operations** within a controlled cloud environment.

---

# 👨‍💻 Author

**Udeesha Rathnayaka**
