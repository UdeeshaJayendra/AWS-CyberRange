# SSH Attack Simulation & Investigation

## 1. Objective

Simulate unauthorized SSH access attempts against the AWS CyberRange target and verify that the activity is logged, detected, and investigated.

## 2. Target

- Public IP: 13.232.192.253
- Private IP: 10.50.1.231
- Instance ID: i-0c405c716f97d7e73
- Operating System: Ubuntu 24.04
- SSH Service: OpenSSH
- AWS Region: ap-south-1

## 3. Attack Simulation

An unauthorized SSH login attempt was performed using the non-existent username:

`fakeuser`

The source IP was:

`61.245.169.129`

The attempt was rejected by the SSH service.

## 4. Evidence

The target recorded the following events in `/var/log/auth.log`:

- Invalid user `fakeuser` from `61.245.169.129`
- Connection reset by invalid user during pre-authentication

The same events were successfully forwarded to Amazon CloudWatch Logs.

## 5. Detection

CloudWatch Logs were filtered using the pattern:

`"Invalid user"`

The detection returned three suspicious SSH events.

A Python detection script was also created:

`scripts/detect_ssh.py`

The script successfully identified:

`Total suspicious SSH attempts: 2`

during the initial investigation.

## 6. Hardening

SSH password authentication was disabled using:

`PasswordAuthentication no`

The SSH configuration was validated with:

`sshd -t`

The SSH service was then reloaded.

## 7. Retesting

After hardening, the same unauthorized SSH attempt was performed again.

Result:

`Permission denied (publickey).`

The post-hardening attempt was also recorded by CloudWatch Logs.

## 8. Result

The CyberRange successfully demonstrated:

1. Unauthorized SSH activity can be simulated in a controlled environment.
2. SSH authentication events are recorded locally.
3. Logs are centralized in Amazon CloudWatch.
4. Suspicious activity can be detected using log filtering.
5. A Python script can identify suspicious SSH attempts.
6. SSH authentication can be hardened.
7. The hardened configuration can be retested.
8. Security logging and detection continue to function after hardening.

## 9. Conclusion

The AWS CyberRange successfully demonstrated a complete security testing workflow:

Attack Simulation → Logging → Detection → Investigation → Hardening → Retesting