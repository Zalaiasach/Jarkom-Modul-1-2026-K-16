#!/bin/sh
# ==========================================================
# SETUP FTP SERVER & TELNET DI NODE CHISA (192.219.2.2)
# ==========================================================
set -e

echo "[+] Memperbarui repositori dan menginstal paket di Chisa..."
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
apk update
apk add vsftpd busybox-extras lftp curl

# Daftarkan shell sistem yang sah
grep -qxF '/bin/sh' /etc/shells || echo '/bin/sh' >> /etc/shells
grep -qxF '/bin/bash' /etc/shells 2>/dev/null || echo '/bin/bash' >> /etc/shells

# Siapkan folder data bersama dan privilege separation
mkdir -p /var/wired/data
mkdir -p /usr/share/empty /var/run/vsftpd/empty
mkdir -p /root/vsftpd_conf/user_conf

# Tambahkan grup dan akun user
addgroup wired 2>/dev/null || true
adduser -D -h /var/wired/data -G wired -s /bin/sh alice 2>/dev/null || true
adduser -D -h /var/wired/data -G wired -s /bin/sh mika 2>/dev/null || true
adduser -D -h /var/wired/data -G wired -s /bin/sh eiri 2>/dev/null || true

# Atur password user
echo "alice:alice123" | chpasswd
echo "mika:mika123" | chpasswd
echo "eiri:eiri123" | chpasswd

# Buka status password locked di Alpine
passwd -u alice 2>/dev/null || true
passwd -u mika 2>/dev/null || true
passwd -u eiri 2>/dev/null || true

# Atur hak kepemilikan dan hak akses direktori
chown -R alice:wired /var/wired/data
chmod -R 775 /var/wired/data

# Buat file manifesto untuk pengujian unduh Mika
echo "Protocol 7: All information must flow freely across The Wired." > /var/wired/data/protocol7_manifesto.txt
chown alice:wired /var/wired/data/protocol7_manifesto.txt
chmod 644 /var/wired/data/protocol7_manifesto.txt

# Buat file konfigurasi utama vsftpd
cat << 'EOF' > /root/vsftpd_conf/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
seccomp_sandbox=NO
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
user_config_dir=/root/vsftpd_conf/user_conf
userlist_enable=YES
userlist_file=/root/vsftpd_conf/vsftpd.userlist
userlist_deny=YES
EOF

# Daftarkan Eiri ke dalam blacklist FTP
echo "eiri" > /root/vsftpd_conf/vsftpd.userlist

# Atur hak akses per-user (Alice: Read-Write, Mika: Read-Only)
echo "write_enable=YES" > /root/vsftpd_conf/user_conf/alice
echo "local_root=/var/wired/data" >> /root/vsftpd_conf/user_conf/alice

echo "write_enable=NO" > /root/vsftpd_conf/user_conf/mika
echo "local_root=/var/wired/data" >> /root/vsftpd_conf/user_conf/mika

# Jalankan / restart service vsftpd
killall vsftpd 2>/dev/null || true
/usr/sbin/vsftpd /root/vsftpd_conf/vsftpd.conf &

# ----------------------------------------------------------
# Setup Telnet Server (Soal Pembuktian Plaintext)
# ----------------------------------------------------------
echo "[+] Menyiapkan akun Telnet phantom_user..."
adduser -D -s /bin/sh phantom_user 2>/dev/null || true
echo "phantom_user:wired_ghost" | chpasswd
passwd -u phantom_user 2>/dev/null || true

killall telnetd 2>/dev/null || true
telnetd -p 23

echo "[✓] Konfigurasi di Chisa (192.219.2.2) selesai!"
echo "    - FTP Server aktif di port 21"
echo "    - Telnet Server aktif di port 23"
netstat -tlpn | grep -E ':21|:23'
