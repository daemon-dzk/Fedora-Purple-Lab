# 🔒 Fedora Hardening Guide

## 1. Firewall Configuration
- **Default zone:** `public`
- **Allowed services:** SSH only
- **Permanent config:** safe to `/etc/firewalld/`

## 2. Disabled Services
| Service | Reason |
|---------|--------|
| `bluetooth` | BlueBorne |
| `geoclue` | Privacy location tracking |
| `cups-browsed` | Remote print vulnerability 

## 3. Kernel Hardening (`/etc/sysctl.d/99-hardening.conf`)
- `rp_filter=1` - Source validation
- `tcp_syncookies=1` - Prevent SYN flood
- `disable_ipv6=1` - disable IPv6 (minimize attack surface)

## 4. GNOME Privacy Settings
- `remember-recent-files=false`
- `remove-old-temp-files=true`
- `remove-old-trash-files=true`

## Cara Verifikasi
```bash
sudo firewall-cmd --list-all
sudo sysctl -a | grep -E "rp_filter|syncookies|disable_ipv6"
gsettings list-recursively org.gnome.desktop.privacy