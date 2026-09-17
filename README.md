# Laporan Modul 1 K-16
namaku   
namanya   

## Setup GNS dan pengerjaan Soal 1-13
Pertama, kita akan menaruh node node yang diperlukan di GNS3 yaitu node Alice, Mika, Chisa, Knights, Eiri, dan yang terakhir untuk router, Lain. Setelah itu node Alice dan Mika disambungkan dengan switch yang sama (swicth 1), lalu Chisa disambung switch 2, kemudian Knights dan Eiri tersambung ke switch yang sama juga (switch 3)   
Lalu, router Lain disambungkan dengan NAT agar bisa mengakses internet yang kemudian router lain disambungkan ke semua switch.   
Berikutnya, setting IP dengan IP Prefix untuk kelompok kami yaitu 192.219.x.x   
Lakukan setting di Router Lain untuk setiap eth nya, eth 0 tersambung ke NAT, eth1 tersambung ke ip 192.219.1.1, eth2 tersambung ke ip 192.219.2.1, eth3 ke ip 192.219.3.1.   
Lalu setiap node diconfigure sesuai dengan 192.219.x.x sesuai dengan soal.
setelah itu, kami akan mengkonfigurasi router lain dengan .bashrc yang berisi:   
```sh
sysctl -w net.ipv4.ip_forward=1


iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "nameserver 8.8.8.8" > /etc/resolv.conf

```

ini digunakan agar setiap node dapat akses ke internet langsung dan bisa dibuktikan dengan ping   
![ping](/img/Nomor4/nomor4BuktiPing.png)   
Setelah berhasil tersambung, kita akan membuat suatu script verifikasi   
```sh
#!/bin/sh
echo "=========================================="
echo "      STATUS INTERFACE ROUTER LAIN        "
echo "=========================================="
ip -br a
echo ""
echo "=========================================="
echo "          TABEL NAT (IPTABLES)            "
echo "=========================================="
iptables -t nat -L -v -n
echo "=========================================="
```
![cekStatus](/img/Nomor5/nomor5CekStatus.png)   

Berikutnya saya akan melakukan kami akan melakukan pengujian pada node Mika dengan script
```sh
#!/bin/bash
# ============================================
# Traffic Generator — Protocol 7 Network
# Serial Experiments Lain — Modul 1 Jarkom 2026
# Jalankan di node MIKA untuk generate traffic DNS & ICMP
# ============================================

echo "============================================"
echo "  Protocol 7 Traffic Generator v2026"
echo "  Node: Mika Iwakura"
echo "============================================"
echo "[*] Generating DNS & ICMP traffic..."

# ICMP Traffic
ping -c 5 8.8.8.8 &
ping -c 5 1.1.1.1 &
ping -c 3 its.ac.id &

# DNS Queries
nslookup google.com 8.8.8.8 &
nslookup its.ac.id 8.8.8.8 &
nslookup github.com 1.1.1.1 &
dig @8.8.8.8 example.com A &
dig @1.1.1.1 cloudflare.com AAAA &

wait
echo "[*] Traffic generation complete."
echo "[*] Check Wireshark for captured packets."

```
dengan hasil berikut   
![buktiwireshark](/img/Nomor6/Nomor6BuktiWireShark1%20(1).png)
![buktiwireshark](/img/Nomor6/Nomor6BuktiWireShark1%20(2).png)
![buktiwireshark](/img/Nomor6/Nomor6BuktiWireShark1%20(3).png)

Setelah itu kita akan mendirikan FTP di chisa yang dimana kita membutuhkan vsftpd sehingga kita akan menginstall dengan command ``` apk add vsftpd ``` yang kemudian bisa kita buat semua masukan script sebagai berikut   
```sh
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

```