import re

LOG_FILE = "ssh_events.log"

pattern = re.compile(
    r"Invalid user (\S+) from (\S+) port (\d+)"
)

print("=== SSH Suspicious Activity Detection ===")

with open(LOG_FILE, "r", encoding="utf-8") as file:
    content = file.read()

matches = pattern.findall(content)

for username, source_ip, port in matches:
    print("[ALERT] Invalid SSH user detected")
    print(f"        Username : {username}")
    print(f"        Source IP: {source_ip}")
    print(f"        Port     : {port}")
    print()

print(f"Total suspicious SSH attempts: {len(matches)}")