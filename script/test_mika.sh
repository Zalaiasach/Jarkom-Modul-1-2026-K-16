#!/bin/sh
# ==========================================================
# SKRIP PENGUJIAN DARI NODE MIKA (192.219.1.3)
# ==========================================================
IP_CHISA="192.219.2.2"
IP_KNIGHTS="192.219.3.2"

echo "[+] Menyiapkan paket di Mika..."
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
apk add lftp curl openssh-client

echo ""
echo "[+] 1. Menguji Akses Read-Only di FTP Chisa ($IP_CHISA)..."
echo "Test unauthorized upload from Mika" > /root/mika_unauthorized.txt

# Download dan coba upload
lftp -u mika,mika123 "$IP_CHISA" << 'EOF' > /root/bukti_readonly_mika.txt 2>&1
set ftp:passive-mode true
get protocol7_manifesto.txt -o /root/protocol7_manifesto.txt
put /root/mika_unauthorized.txt
bye
EOF

cat /root/bukti_readonly_mika.txt
echo "[✓] Pengujian Read-Only selesai. Log tersimpan di /root/bukti_readonly_mika.txt"

echo ""
echo "[+] 2. Menyiapkan Pasangan Kunci SSH untuk mika_admin..."
adduser -D -s /bin/sh mika_admin 2>/dev/null || true
mkdir -p /home/mika_admin/.ssh
chmod 700 /home/mika_admin/.ssh

if [ ! -f /home/mika_admin/.ssh/id_rsa ]; then
    su mika_admin -c "ssh-keygen -t rsa -b 2048 -f /home/mika_admin/.ssh/id_rsa -N ''"
fi

echo "=========================================================="
echo "KUNCI PUBLIK MIKA (Salin ke authorized_keys di Knights):"
echo "=========================================================="
cat /home/mika_admin/.ssh/id_rsa.pub
echo "=========================================================="
echo ""
echo "Perintah login setelah kunci dipasang di Knights:"
echo "su mika_admin -c \"ssh -o StrictHostKeyChecking=no mika_admin@$IP_KNIGHTS\""
