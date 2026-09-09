# AWS CyberRange — Cloud Attack Simulation & Defense Lab

[![AWS](https://img.shields.io/badge/AWS-Cloud-orange)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-purple)](https://www.terraform.io/)
[![Ubuntu](https://img.shields.io/badge/OS-Ubuntu-E95420)](https://ubuntu.com/)
[![Python](https://img.shields.io/badge/Python-3.x-blue)](https://www.python.org/)
[![Nmap](https://img.shields.io/badge/Security-Nmap-green)](https://nmap.org/)
[![CloudWatch](https://img.shields.io/badge/Amazon-CloudWatch-blue)](https://aws.amazon.com/cloudwatch/)
[![IAM](https://img.shields.io/badge/AWS-IAM-red)](https://aws.amazon.com/iam/)
[![VPC](https://img.shields.io/badge/AWS-VPC-purple)](https://aws.amazon.com/vpc/)
[![SSH](https://img.shields.io/badge/Protocol-SSH-black)](https://www.openssh.com/)
[![Git](https://img.shields.io/badge/Git-Version%20Control-orange)](https://git-scm.com/)

> An authorized AWS-based cybersecurity lab for simulating controlled attacks, collecting security evidence, detecting suspicious activity, applying defensive controls, and validating the results through retesting.

---

##  Overview

**AWS CyberRange** is a hands-on cloud security laboratory built on **Amazon Web Services (AWS)** and provisioned using **Terraform**.

The project demonstrates a complete security testing workflow:

```text
Deploy → Reconnaissance → Attack Simulation → Detection
       → Investigation → Hardening → Retesting
```

Instead of only building secure cloud infrastructure, this project focuses on **simulating attacks against a controlled AWS environment and investigating the resulting evidence**.

All security testing was performed against infrastructure owned and controlled for this lab.

---

##  Objectives

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

##  Architecture

The CyberRange consists of an AWS VPC containing a public subnet and an EC2 target machine.

<img width="1408" height="768" alt="5" src="https://github.com/user-attachments/assets/b90f0538-4bbe-4688-a9d7-29072c0d2198" />


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

##  AWS Services Used

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

##  Security Design

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
This allows the SSH attack simulation to be performed from the authorized testing machine while preventing unrestricted SSH exposure.

---

##  Infrastructure as Code

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

This helps prevent unnecessary AWS resource usage and costs.

---

##  Phase 1 — Network Reconnaissance

After deploying the target, authorized reconnaissance was performed using **Nmap**.

The objective was to identify:

* Open ports
* Available services
* Service versions
* Network exposure

### Nmap Service Scan

The scan identified the HTTP service running on port `80`.

Example result:

```text
PORT   STATE SERVICE VERSION
80/tcp open  http    nginx 1.24.0 (Ubuntu)
```

### Screenshot

<img width="1592" height="413" alt="01-nmap-service-scan png" src="https://github.com/user-attachments/assets/fc91e95f-9e65-4245-8238-2c5624fe00c2" />

---

## 🌐 Phase 2 — HTTP Enumeration

HTTP enumeration was performed against the controlled web server.

This confirmed that the web service was reachable.

### Screenshot
<img width="1566" height="312" alt="02-http-enumeration png" src="https://github.com/user-attachments/assets/8fd256d4-4384-474d-a681-2ea4f743a4f0" />


---

# 🚨 Phase 3 — Controlled SSH Attack Simulation

A controlled SSH authentication attack was performed against the CyberRange target.

The simulated username was:

```text
fakeuser
```

The purpose was **not to gain unauthorized access**, but to generate realistic authentication events that could be detected and investigated.

---

## 📝 Authentication Evidence

The SSH authentication logs recorded suspicious activity in:
Example:

```text
Invalid user fakeuser from ATTACKER_IP port 16611
Connection reset by invalid user fakeuser ATTACKER_IP port 16611 [preauth]

Invalid user fakeuser from ATTACKER_IP port 16614
Connection reset by invalid user fakeuser ATTACKER_IP port 16614 [preauth]
```

These events provide evidence that an invalid SSH account was being used against the target.

### Screenshot

<img width="1588" height="371" alt="03-ssh-detection png" src="https://github.com/user-attachments/assets/76ecf4ac-2c6e-47bb-b2d6-35272bd452ea" />


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

<img width="1907" height="835" alt="08-cloudwatch-logs" src="https://github.com/user-attachments/assets/df947bc1-4b23-45f5-9463-698ee21fe889" />


#  Phase 5 — VPC Flow Logs

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
<img width="1906" height="707" alt="09-vpc-flow-logs" src="https://github.com/user-attachments/assets/16ecedaa-6f69-49c6-bb19-a7c3294a7710" />


# 🧠 Phase 6 — SSH Detection Script

A Python detection script was developed to identify suspicious SSH authentication events.

The script searches for log entries matching:
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

<img width="1588" height="371" alt="03-ssh-detection png" src="https://github.com/user-attachments/assets/127b86fe-cf9e-4535-8689-893559252ee3" />

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

<img width="1598" height="237" alt="04-cloudwatch-ssh-detection-after-hardening png" src="https://github.com/user-attachments/assets/89b5d501-a160-4658-9268-711a2118646c" />


---

#  Before vs After

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

* Final security assessment

---

# 📸 AWS Infrastructure Evidence

The project also includes screenshots showing the deployed AWS infrastructure.

### AWS VPC
<img width="1910" height="760" alt="05-aws-vpc" src="https://github.com/user-attachments/assets/97f5e45d-f58f-4596-ba5f-1b14edc0bb93" />


### EC2 Target
<img width="1868" height="660" alt="06-aws-ec2-target" src="https://github.com/user-attachments/assets/baf03c56-38f6-4ddc-a193-962f0165fa7f" />

### Security Group
<img width="1653" height="506" alt="07-aws-security-group" src="https://github.com/user-attachments/assets/3a95dfa6-f976-4d05-8cf2-71ab2522ada8" />

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


# 👨‍💻 Author

**Udeesha Rathnayaka**
