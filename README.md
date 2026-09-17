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