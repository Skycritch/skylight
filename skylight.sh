#!/bin/bash

# ============================= SKYLIGHT HEADER ============================= #
# v1.02 by Skycritch
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
By: Skycritch v.1.02  https://github.com/Skycritch/skylight/
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

# === FULL GTFOBins TOOL LIST ===
# Snapshot as of 2025-08-19 (static list)
GTFO_TOOLS=(
  aa-exec ab agetty alpine ansible-playbook apt apt-get ar aria2c arj arp as ascii-xfr
  ash aspell at atobm awk base32 base64 basenc basez bash bc batcat bpftrace bridge
  bundler busctl busybox bzip2 c89 c99 cabal capsh cancel cat certbot check_by_ssh
  check_cups check_log check_memory check_raid check_ssl_cert check_statusfile chmod
  choom chown chroot clamscan cobc cmp column comm composer cowsay cowthink cp cpan
  cpio cpulimit crash crontab csh csplit csvtool cupsfilter curl cut dash date dd
  debugfs dc dialog diff dig dmesg dmidecode dmsetup dnf docker dosbox dpkg dvips eb
  ed efax elvish emacs env eqn ex exiftool expand expect facter file find finger
  fish flock fmt fold ftp gawk gcc gcore gdb gemp gem genisoimage ghc ghci gimp git
  gtester grep gzip hd head hexdump highlight hping3 iconv iftop install ionice ip
  irb ispell jjs joe join journalctl jq jrunscript julia ksh ksshell kubectl ld.so
  ldconfig latex lftp less links logsave look ltrace lua lualatex luatex mail make
  man mawk minicom more mount mosquitto msgattrib msgcat msgconv msgfilter msgmerge
  msguniq mtr multitime mv mysql nano nasm nawk nc ncdu ncftp nft nice nl nm nmap
  node nohup ntpdate octave od openssl openvpn pandoc paste pdflatex pdftex perf perl
  pexec pg php pic pico pip pidstat posh pr pry psftp puppet ptx python python3 rc
  readelf red restic rev rlogin rlwrap rpm rpmdb rpmquery rpmverify rsync rtorrent
  ruby run-mailcap run-parts runscript rview rvim sash scanmem scp scrot sed setarch
  setfacl setlock sh shuf soelim socat softlimit sort sqlite3 ss ssh-agent ssh-keygen
  ssh-keyscan sshpass start-stop-daemon stdbuf strace strings sysctl systemctl tac
  tail tar taskset tasksh tbl tclsh tdbtool tee telnet terraform tex tftp tic time
  timeout tmate troff ul unexpand uniq unshare unsquashfs unzip update-alternatives
  uudecode uuencode vagrant varnishncsa view vigr vim vimdiff vipw w3m watch wc wget
  whiptail xargs xdotool xetex xelatex xmodmap xmore xxd xz yash zip zsh
)

# Build a safe regex from the array (escape regex metacharacters)
GTFOS_REGEX=$(
  printf '%s\n' "${GTFO_TOOLS[@]}" \
  | sed 's/[.[\()*^$+?{}|\\]/\\&/g' \
  | paste -sd'|' -
)

# === SUID/SGID ENUM & EXPLOITABLE LIST ===
echo -e "${BLU}--- SUID / SGID BINARIES ---${NC}"
SUID=$(find / -perm -4000 -type f 2>/dev/null | sort -u)
SGID=$(find / -perm -2000 -type f 2>/dev/null | sort -u)

# Show ALL SUID/SGID first
echo -e "${GRN}[+] Total SUID binaries: $(printf '%s\n' "$SUID" | grep -c .)${NC}"
if [[ -n "$SUID" ]]; then
  printf "%s\n" "$SUID"
else
  echo "(none)"
fi

echo -e "\n${GRN}[+] Total SGID binaries: $(printf '%s\n' "$SGID" | grep -c .)${NC}"
if [[ -n "$SGID" ]]; then
  printf "%s\n" "$SGID"
else
  echo "(none)"
fi

# Informational: SGID overlaps with GTFOBins
if printf '%s\n' "$SGID" | grep -Eq "$GTFOS_REGEX"; then
  echo -e "${YEL}[*] Note: Some SGID binaries match GTFOBins (informational).${NC}"
fi

# Build exploitable SUID list (SUID + GTFOBins overlap)
exploitable_suid="$(printf '%s\n' "$SUID" | grep -E "$GTFOS_REGEX" 2>/dev/null || true)"

echo -e "\n${BLU}--- EXPLOITABLE SUID (GTFOBins overlap) ---${NC}"
if [[ -n "$exploitable_suid" ]]; then
  echo -e "${RED}[!] Exploitable SUID GTFOBins detected:${NC}"
  printf "%s\n" "$exploitable_suid"
else
  echo -e "${GRN}[+] No SUID binaries matched known GTFOBins.${NC}"
fi

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

# === RISK ENGINE (1–100 scale) ===
echo -e "${YEL}[*] Skylight PrivEsc Risk Engine (1–100):${NC}"

risk=0
add_risk() { local add=${1:-0}; risk=$(( risk + add )); [ $risk -gt 100 ] && risk=100; }

# Full NOPASSWD sudo
if grep -q 'NOPASSWD.*ALL' /tmp/.sudo_skylight 2>/dev/null; then
    echo -e "${RED}[+] Full NOPASSWD sudo rights detected (+35)${NC}"
    add_risk 35
# Limited NOPASSWD sudo (GTFO paths)
elif grep -Eq 'NOPASSWD|/bin/bash|vim|less|more|perl|python' /tmp/.sudo_skylight 2>/dev/null; then
    echo -e "${RED}[+] Limited NOPASSWD sudo (GTFOBin vector) (+30)${NC}"
    add_risk 30
fi

# Writable cron target
cron_targets=$(grep -Po '(?<=\s)(/[^ >]++)' /etc/crontab 2>/dev/null)
for file in $cron_targets; do
  if [ -w "$file" ]; then
    echo -e "${RED}[+] Writable cron target: $file (+25)${NC}"
    add_risk 25
  fi
done

# High-risk SUID GTFOBins (force overall severity to CRITICAL if any)
if [[ -n "$exploitable_suid" ]]; then
    echo -e "${RED}[+] Exploitable SUID GTFOBins present (+35, severity floor=CRITICAL)${NC}"
    add_risk 35
    # Force at least CRITICAL (80/100) overall
    if [ $risk -lt 80 ]; then risk=80; fi
fi

# Dangerous capabilities
if command -v getcap >/dev/null 2>&1; then
    if getcap -r / 2>/dev/null | grep -qE 'cap_sys_admin|cap_setuid|cap_dac_override'; then
        echo -e "${RED}[+] Dangerous capabilities detected (+15)${NC}"
        add_risk 15
    fi
fi

# PATH hijack
for dir in "${dirs[@]}"; do
    if [ -w "$dir" ]; then
        echo -e "${RED}[+] Writable dir in \$PATH: $dir (+12)${NC}"
        add_risk 12
    fi
done

# Docker escape surface
if id | grep -q docker; then
    echo -e "${RED}[+] User in docker group (+12)${NC}"
    add_risk 12
fi
if [ -S /var/run/docker.sock ]; then
    echo -e "${RED}[+] Docker socket exposed (+12)${NC}"
    add_risk 12
fi

# SSH agent
if [[ "$SSH_AUTH_SOCK" ]]; then
    echo -e "${RED}[+] SSH Agent forwarding enabled (+8)${NC}"
    add_risk 8
fi

# AWS metadata
if curl -s --max-time 1 http://169.254.169.254/latest/meta-data/ | grep -q 'instance-id'; then
    echo -e "${RED}[+] AWS instance metadata accessible (+8)${NC}"
    add_risk 8
fi

# Config secrets
if grep -iR 'password\|secret\|token' /etc /home 2>/dev/null | head -n 5 | grep -q .; then
    echo -e "${RED}[+] Config file credentials found (+8)${NC}"
    add_risk 8
fi

# SSH keys
if find /home -name id_rsa 2>/dev/null | grep -q .; then
    echo -e "${RED}[+] SSH private keys found (+6)${NC}"
    add_risk 6
fi

# Common SUIDs (signal only)
if printf '%s\n' "$SUID" | grep -qE '/usr/bin/mount|/usr/bin/umount'; then
    echo -e "${YEL}[*] Common SUIDs (mount/umount) (+4)${NC}"
    add_risk 4
fi

# ==== Final Risk Score (1–100) ====
echo -e "\n${BLU}--- FINAL RISK SCORE ---${NC}"
echo -e "${BOLD}Total Risk Points: $risk/100${NC}"

# Severity bands 
if   [ $risk -ge 80 ]; then
    echo -e "${RED}${BOLD}[CRITICAL] Immediate privilege escalation path likely!${NC}"
elif [ $risk -ge 60 ]; then
    echo -e "${RED}[HIGH] PrivEsc paths likely exploitable.${NC}"
elif [ $risk -ge 30 ]; then
    echo -e "${YEL}[MEDIUM] Misconfigs or indirect paths available.${NC}"
else
    echo -e "${GRN}[LOW] No immediate privesc detected.${NC}"
fi

# === CLEANUP ===
echo -e "${YEL}[*] Skylight scan complete at $(date)${NC}"
echo -e "${GRN}[+] Results logged to: $LOGFILE${NC}"
