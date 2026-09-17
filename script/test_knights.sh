#!/bin/sh
# ==========================================================
# SKRIP PENGUJIAN DARI NODE KNIGHTS (192.219.3.2)
# ==========================================================
IP_CHISA="192.219.2.2"

echo "[+] 1. Upload knights_report.txt ke FTP Chisa ($IP_CHISA) via akun Alice..."
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

cat << 'EOF' > /root/knights_report.txt
Knights Protocol Report: Data synchronization with The Wired complete.
EOF

apk add lftp 2>/dev/null || true
lftp -u alice,alice123 "$IP_CHISA" -e "set ftp:passive-mode true; put /root/knights_report.txt; bye"
echo "[✓] Berkas knights_report.txt berhasil diunggah ke Chisa!"

echo ""
echo "[+] 2. Menjalankan Ping Terkontrol ke Chisa ($IP_CHISA)..."
echo "     (77 paket, payload 128 bytes, jeda 0.3 detik)"
ping -s 128 -i 0.3 -c 77 "$IP_CHISA"
echo "[✓] Pengiriman paket ICMP selesai!"
