#!/bin/sh
# ==========================================================
# SETUP NODE KNIGHTS (192.219.3.2)
# ==========================================================
set -e

echo "[+] Memperbarui repositori dan memasang paket di Knights..."
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

apk update
apk add openssh busybox-extras

# Pastikan shell terdaftar
grep -qxF '/bin/sh' /etc/shells || echo '/bin/sh' >> /etc/shells

# Setup akun mika_admin untuk SSH Public Key Auth
echo "[+] Membuat akun mika_admin..."
adduser -D -s /bin/sh mika_admin 2>/dev/null || true
echo "mika_admin:mika123" | chpasswd
passwd -u mika_admin 2>/dev/null || true

# Siapkan folder .ssh untuk mika_admin
mkdir -p /home/mika_admin/.ssh
chmod 755 /home/mika_admin
chmod 700 /home/mika_admin/.ssh
chown -R mika_admin:mika_admin /home/mika_admin

# Generate host keys SSH jika belum ada
ssh-keygen -A 2>/dev/null || true

# Konfigurasi SSH Daemon (Hanya Public Key, Password Auth Mati)
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
grep -qxF 'PubkeyAuthentication yes' /etc/ssh/sshd_config || echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
grep -qxF 'PasswordAuthentication no' /etc/ssh/sshd_config || echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
grep -qxF 'AuthorizedKeysFile .ssh/authorized_keys' /etc/ssh/sshd_config || echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config

# Jalankan service SSH (Port 22)
killall sshd 2>/dev/null || true
/usr/sbin/sshd

# Jalankan HTTP Server sederhana di port 80 untuk port scanning
mkdir -p /var/www/localhost/htdocs
killall httpd 2>/dev/null || true
httpd -p 80 -h /var/www/localhost/htdocs

# Pastikan port 7777 tertutup (tidak ada proses listening)
fuser -k 7777/tcp 2>/dev/null || true

echo "[✓] Setup Knights (192.219.3.2) selesai!"
echo "    - Port 22 (SSH): LISTEN"
echo "    - Port 80 (HTTP): LISTEN"
echo "    - Port 7777: CLOSED"
netstat -tlpn | grep -E ':22|:80|:7777'
