#!/bin/sh
# ==========================================================
# SKRIP PENGUJIAN DARI NODE ALICE (192.219.1.2)
# ==========================================================
set -e

IP_CHISA="192.219.2.2"
IP_KNIGHTS="192.219.3.2"

echo "[+] Menyiapkan paket pendukung di Alice..."
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf

apk add lftp curl netcat-openbsd 2>/dev/null || apk add lftp curl busybox-extras

echo "[+] 1. Mengunggah file bukti signal_alice.txt ke FTP Chisa ($IP_CHISA)..."
echo "Signal Alice: The Wired is synchronized." > /root/signal_alice.txt

lftp -u alice,alice123 "$IP_CHISA" -e "set ftp:passive-mode true; put /root/signal_alice.txt; bye"
echo "[✓] File signal_alice.txt berhasil diunggah ke FTP Chisa!"

echo ""
echo "[+] 2. Melakukan Port Scanning ke Knights ($IP_KNIGHTS)..."
echo "--- Hasil Scan Port (22, 80, 7777) ---"
nc -zv -w 2 "$IP_KNIGHTS" 22 80 7777 > /root/hasil_scan_port.txt 2>&1 || true
cat /root/hasil_scan_port.txt
echo "[✓] Port scan selesai. Hasil disimpan di /root/hasil_scan_port.txt"
