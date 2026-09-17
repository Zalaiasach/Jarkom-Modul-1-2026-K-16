#!/bin/sh
# ==========================================================
# SKRIP PENGUJIAN DARI NODE EIRI (192.219.3.3)
# ==========================================================
IP_CHISA="192.219.2.2"

echo "[+] 1. Menguji Penolakan Login FTP (Blacklist) ke Chisa ($IP_CHISA)..."
nc "$IP_CHISA" 21 << 'EOF' > /root/bukti_penolakan_eiri.txt 2>&1
USER eiri
PASS eiri123
QUIT
EOF

echo "--- Isi Bukti Penolakan FTP ---"
cat /root/bukti_penolakan_eiri.txt
echo "[✓] Bukti penolakan FTP tersimpan di /root/bukti_penolakan_eiri.txt"

echo ""
echo "[+] 2. Pengujian Login Telnet ke Chisa ($IP_CHISA) via Wireshark..."
echo "Jalankan perintah interaktif berikut:"
echo "telnet $IP_CHISA"
echo "Username: phantom_user"
echo "Password: wired_ghost"
