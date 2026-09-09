#!/bin/bash
# fedora-purple-lab: Automated Security & CTF Toolkit for Fedora GNOME
# Author: [Nama kamu]
# Version: 0.1.0

set -e

# --- Color Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Functions ---
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[*]${NC} $1"
}

# --- Check Root ---
if [[ $EUID -eq 0 ]]; then
   print_error "Jangan jalankan sebagai root! Pakai sudo di dalam script."
   exit 1
fi

# --- Main Menu ---
show_menu() {
    echo "=========================================="
    echo "  🛡️  FEDORA PURPLE LAB SETUP MENU"
    echo "=========================================="
    echo "1. Full Setup (Tools + Hardening)"
    echo "2. Install CTF Tools Only"
    echo "3. Apply Hardening Only"
    echo "4. Setup CTF Workspace (folder terenkripsi)"
    echo "5. Exit"
    echo "=========================================="
    read -p "Pilih opsi [1-5]: " choice
    case $choice in
        1) full_setup ;;
        2) install_tools ;;
        3) apply_hardening ;;
        4) setup_workspace ;;
        5) exit 0 ;;
        *) print_error "Pilihan salah!"; show_menu ;;
    esac
}

# --- Install CTF Tools ---
install_tools() {
    print_status "Menginstall CTF Tools..."
    
    # Update system
    sudo dnf update -y
    
    # Install essential groups
    sudo dnf groupinstall -y "Development Tools" "Security Lab"
    
    # Install individual tools
    print_status "Installing network tools..."
    sudo dnf install -y nmap wireshark tcpdump ngrep hping3 masscan
    
    print_status "Installing web tools..."
    sudo dnf install -y nikto sqlmap httrack wfuzz
    
    print_status "Installing forensics tools..."
    sudo dnf install -y binwalk foremost testdisk sleuthkit autopsy volatility3
    
    print_status "Installing cracking tools..."
    sudo dnf install -y john hydra medusa hashcat
    
    print_status "Installing reverse engineering tools..."
    sudo dnf install -y ghidra radare2 ltrace strace
    
    print_status "Installing vulnerability scanners..."
    sudo dnf install -y lynis chkrootkit rkhunter clamav
    
    print_status "Installing Python tools..."
    pip3 install --user pwntools impacket requests beautifulsoup4 scapy
    
    print_status "Tools installation selesai!"
}

# --- Apply Hardening ---
apply_hardening() {
    print_status "Menerapkan Hardening..."
    
    # Firewall configuration
    print_info "Configuring firewall..."
    sudo firewall-cmd --set-default-zone=public
    sudo firewall-cmd --add-service=ssh --permanent
    sudo firewall-cmd --runtime-to-permanent
    sudo systemctl enable firewalld
    
    # Disable unnecessary services
    print_info "Disabling insecure services..."
    sudo systemctl mask bluetooth.service
    sudo systemctl mask geoclue.service
    sudo systemctl mask cups-browsed.service
    
    # Kernel hardening (sysctl)
    print_info "Applying kernel hardening..."
    cat << EOF | sudo tee /etc/sysctl.d/99-hardening.conf
# Network hardening
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_rfc1337=1

# Disable IPv6
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF
    sudo sysctl -p /etc/sysctl.d/99-hardening.conf
    
    # GNOME privacy settings
    print_info "Configuring GNOME privacy..."
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
    
    print_status "Hardening selesai!"
}

# --- Setup CTF Workspace ---
setup_workspace() {
    print_status "Membuat CTF Workspace..."
    
    WORKSPACE="$HOME/CTF-Workspace"
    
    # Create encrypted folder
    print_info "Membuat folder terenkripsi (LUKS)..."
    sudo dd if=/dev/urandom of="$HOME/ctf-container.img" bs=1M count=1024
    sudo cryptsetup luksFormat "$HOME/ctf-container.img"
    sudo cryptsetup open "$HOME/ctf-container.img" ctf_volume
    sudo mkfs.ext4 /dev/mapper/ctf_volume
    mkdir -p "$WORKSPACE"
    sudo mount /dev/mapper/ctf_volume "$WORKSPACE"
    sudo chown -R $USER:$USER "$WORKSPACE"
    
    # Create folder structure
    mkdir -p "$WORKSPACE"/{recon,exploit,notes,flags,logs}
    
    # Create template files
    cat > "$WORKSPACE/notes/template.md" << 'EOF'
# CTF Challenge Notes
## Challenge Name: 
**Category:** 
**Points:** 
**Difficulty:** 

## Recon
- [ ] Nmap scan
- [ ] Directory fuzzing
- [ ] Source code review

## Exploitation
- Vulnerability:
- Exploit steps:
- Payload:

## Flag
flag{}
EOF
    
    print_status "Workspace created di: $WORKSPACE"
    print_info "Untuk mount: sudo cryptsetup open $HOME/ctf-container.img ctf_volume && sudo mount /dev/mapper/ctf_volume $WORKSPACE"
    print_info "Untuk unmount: sudo umount $WORKSPACE && sudo cryptsetup close ctf_volume"
}

# --- Full Setup ---
full_setup() {
    print_status "Menjalankan Full Setup..."
    install_tools
    apply_hardening
    setup_workspace
    print_status "Full setup selesai! Reboot disarankan."
}

# --- Start Script ---
clear
echo "=========================================="
echo "  🐧 FEDORA PURPLE LAB v0.1"
echo "  Cybersecurity Setup for GNOME"
echo "=========================================="
show_menu