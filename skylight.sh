#!/bin/bash

# ============================= SKYLIGHT HEADER ============================= #
# v1.01 by Skycritch
# https://github.com/Skycritch/skylight/

# COLOR SETUP
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YEL=$(tput setaf 3)
BLU=$(tput setaf 4)
NC=$(tput sgr0)
BOLD=$(tput bold)

clear
echo -e "${YEL}${BOLD}"
cat << "EOF"
███████╗██╗  ██╗██╗   ██╗██╗     ██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║ ██╔╝╚██╗ ██╔╝██║     ██║██╔════╝ ██║  ██║╚══██╔══╝
███████╗█████╔╝  ╚████╔╝ ██║     ██║██║  ███╗███████║   ██║   
╚════██║██╔═██╗   ╚██╔╝  ██║     ██║██║   ██║██╔══██║   ██║   
███████║██║  ██╗   ██║   ███████╗██║╚██████╔╝██║  ██║   ██║   
╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝                                                           
==============================================================
By: Skycritch v.1.01  https://github.com/Skycritch/skylight/
EOF
echo -e "${NC}"

# Optional THOROUGH Mode
thorough=0
if [[ "$1" == "--thorough" ]]; then
    thorough=1
    echo -e "${YEL}[+] Running in THOROUGH mode${NC}"
fi

# Log setup
TIMESTAMP=$(date +%s)
HOST=$(hostname)
LOGFILE="/tmp/skylight_${HOST}_${TIMESTAMP}.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo -e "${YEL}[*] Starting Skylight Recon at $(date)${NC}"
echo -e "${GRN}[+] User: $(whoami), Host: $HOST${NC}"

# === SYSTEM INFO ===
echo -e "${BLU}--- SYSTEM INFORMATION ---${NC}"
echo -e "${GRN}[+] Hostname:${NC} $(hostname)"
echo -e "${GRN}[+] Architecture:${NC} $(uname -m)"
echo -e "${GRN}[+] Kernel:${NC} $(uname -a)"
cat /proc/version
cat /etc/*-release 2>/dev/null | uniq

# === KERNEL EXPLOIT SUGGESTIONS ===
echo -e "${BLU}--- KERNEL EXPLOIT CHECK ---${NC}"
if command -v searchsploit >/dev/null 2>&1; then
    searchsploit "$(uname -r)"
else
    echo -e "${RED}[-] searchsploit not available${NC}"
fi

# === FILE CAPABILITIES ===
echo -e "${BLU}--- FILE CAPABILITIES (getcap) ---${NC}"
if command -v getcap >/dev/null 2>&1; then
    getcap -r / 2>/dev/null | grep -Ei 'cap_setuid|cap_net_raw|cap_dac_override|cap_sys_admin'
else
    echo -e "${RED}[-] getcap not installed${NC}"
fi

# === DOCKER ESCAPE ===
echo -e "${BLU}--- DOCKER ESCAPE CHECK ---${NC}"
if [ -S /var/run/docker.sock ]; then
    echo -e "${RED}[!] Docker socket is exposed${NC}"
fi
grep -qa 'docker\|kubepods\|lxc' /proc/1/cgroup && echo "${YEL}[!] Running inside a container${NC}"
id | grep -i docker && echo -e "${RED}[!] User is in docker group${NC}"

# === AWS METADATA ===
echo -e "${BLU}--- CLOUD METADATA / AWS CREDS ---${NC}"
curl -s --max-time 1 http://169.254.169.254/latest/meta-data/ && echo "${YEL}[!] Instance metadata exposed${NC}"
env | grep -i AWS

# === SUDO ENUMERATION ===
echo -e "${BLU}--- SUDO PERMISSIONS ---${NC}"
if sudo -n true 2>/dev/null; then
    echo -e "${RED}[!] Passwordless sudo is enabled${NC}"
    sudo -n -l 2>/dev/null | tee /tmp/.sudo_skylight
    grep -E 'NOPASSWD|ALL|.*\*.*|sh|bash|vi|less|more' /tmp/.sudo_skylight
else
    echo -e "${YEL}[-] No NOPASSWD sudo; skipping sudo -l${NC}"
fi

# === SUID/SGID ENUM ===
echo -e "${BLU}--- SUID / SGID BINARIES ---${NC}"
SUID=$(find / -perm -4000 -type f 2>/dev/null)
SGID=$(find / -perm -2000 -type f 2>/dev/null)
GTFOS="nmap|find|vim|less|bash|cp|more|nano|awk|perl|python|tar|wget|tcpdump|mount|umount"

echo "$SUID" | grep -E "$GTFOS" && echo -e "${RED}[!] GTFOBin-compatible SUIDs found${NC}"
echo "$SGID" | grep -E "$GTFOS" && echo -e "${RED}[!] GTFOBin-compatible SGIDs found${NC}"

# === FILE PERMISSIONS ===
echo -e "${BLU}--- WRITABLE PATHS / HIJACK CHECK ---${NC}"
IFS=':' read -ra dirs <<< "$PATH"
for dir in "${dirs[@]}"; do
    [ -w "$dir" ] && echo -e "${RED}[!] Writable PATH dir: $dir${NC}"
done

# === CRON / SYSTEMD ===
echo -e "${BLU}--- CRON JOBS & TIMERS ---${NC}"
ls -la /etc/cron* /var/spool/cron 2>/dev/null
cat /etc/crontab 2>/dev/null
systemctl list-timers --all 2>/dev/null | head -n 20

# === USERS / GROUPS ===
echo -e "${BLU}--- USERS / GROUPS ENUM ---${NC}"
id
cut -d: -f1 /etc/passwd
awk -F: '$3 == 0 {print $1}' /etc/passwd
lastlog | grep -v "Never"
grep 'sudo' /etc/group

# === NETWORKING ===
echo -e "${BLU}--- NETWORK ENUMERATION ---${NC}"
ip a
ip r
ss -tuln
arp -a
cat /etc/hosts

# === CREDENTIAL HUNTING ===
echo -e "${BLU}--- CREDENTIAL PATTERN SEARCH ---${NC}"
grep -iR 'password\|secret\|token' /etc /home 2>/dev/null | head -n 25

# === SSH / KEYS / AGENTS ===
echo -e "${BLU}--- SSH KEYS & AGENT CHECK ---${NC}"
find /home -name "id_rsa" -o -name "authorized_keys" 2>/dev/null
[[ "$SSH_AUTH_SOCK" ]] && echo -e "${RED}[!] SSH Agent socket set: $SSH_AUTH_SOCK${NC}"

echo -e "${YEL}[*] Skylight PrivEsc Risk Engine:${NC}"

risk=0

# NOPASSWD Sudo
if grep -q 'NOPASSWD.*ALL' /tmp/.sudo_skylight 2>/dev/null; then
    echo -e "${RED}[+] Full NOPASSWD sudo rights detected (+100)${NC}"
    risk=$((risk + 100))
elif grep -Eq 'NOPASSWD|/bin/bash|vim|less|more|perl|python' /tmp/.sudo_skylight 2>/dev/null; then
    echo -e "${RED}[+] Limited NOPASSWD sudo (GTFOBin vector) (+90)${NC}"
    risk=$((risk + 90))
fi

# Writable cron target
cron_targets=$(grep -Po '(?<=\s)(/[^ >]++)' /etc/crontab 2>/dev/null)
for file in $cron_targets; do
  [ -w "$file" ] && echo -e "${RED}[+] Writable cron target: $file (+90)${NC}" && risk=$((risk + 90))
done

# SUID GTFOBins
if echo "$SUID" | grep -Eq 'nmap|vim|perl|python|bash|find|less|more'; then
    echo -e "${RED}[+] Exploitable SUID binary found (GTFOBin) (+70)${NC}"
    risk=$((risk + 70))
fi

# Dangerous capabilities
if command -v getcap >/dev/null 2>&1; then
    if getcap -r / 2>/dev/null | grep -qE 'cap_sys_admin|cap_setuid|cap_dac_override'; then
        echo -e "${RED}[+] Dangerous capabilities detected (+60)${NC}"
        risk=$((risk + 60))
    fi
fi

# PATH hijack
for dir in "${dirs[@]}"; do
    if [ -w "$dir" ]; then
        echo -e "${RED}[+] Writable dir in \$PATH: $dir (+50)${NC}"
        risk=$((risk + 50))
    fi
done

# Docker escape
if id | grep -q docker; then
    echo -e "${RED}[+] User in docker group (+50)${NC}"
    risk=$((risk + 50))
fi
[ -S /var/run/docker.sock ] && echo -e "${RED}[+] Docker socket exposed (+50)${NC}" && risk=$((risk + 50))

# SSH agent
[[ "$SSH_AUTH_SOCK" ]] && echo -e "${RED}[+] SSH Agent forwarding enabled (+40)${NC}" && risk=$((risk + 40))

# AWS metadata
if curl -s --max-time 1 http://169.254.169.254/latest/meta-data/ | grep -q 'instance-id'; then
    echo -e "${RED}[+] AWS instance metadata accessible (+40)${NC}"
    risk=$((risk + 40))
fi

# Config secrets
grep -iR 'password\|secret\|token' /etc /home 2>/dev/null | head -n 5 | grep -q . && \
echo -e "${RED}[+] Config file credentials found (+40)${NC}" && risk=$((risk + 40))

# SSH keys
find /home -name id_rsa 2>/dev/null | grep -q . && \
echo -e "${RED}[+] SSH private keys found (+30)${NC}" && risk=$((risk + 30))

# Normal SUIDs
if echo "$SUID" | grep -qE '/usr/bin/mount|/usr/bin/umount'; then
    echo -e "${YEL}[*] Common SUIDs (mount/umount) (+20)${NC}"
    risk=$((risk + 20))
fi

# ==== Final Risk Score ====

echo -e "\n${BLU}--- FINAL RISK SCORE ---${NC}"
echo -e "${BOLD}Total Risk Points: $risk${NC}"

if [ $risk -ge 180 ]; then
    echo -e "${RED}${BOLD}[CRITICAL] Immediate privilege escalation path likely!${NC}"
elif [ $risk -ge 120 ]; then
    echo -e "${RED}[HIGH] PrivEsc paths likely exploitable.${NC}"
elif [ $risk -ge 50 ]; then
    echo -e "${YEL}[MEDIUM] Misconfigs or indirect paths available.${NC}"
else
    echo -e "${GRN}[LOW] No immediate privesc detected.${NC}"
fi

# === CLEANUP ===
echo -e "${YEL}[*] Skylight scan complete at $(date)${NC}"
echo -e "${GRN}[+] Results logged to: $LOGFILE${NC}"
