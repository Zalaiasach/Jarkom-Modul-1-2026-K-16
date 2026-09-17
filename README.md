# Laporan Modul 1 K-16
namaku   
namanya   

## Setup GNS dan pengerjaan Soal 1-13
Pertama, kita akan menaruh node node yang diperlukan di GNS3 yaitu node Alice, Mika, Chisa, Knights, Eiri, dan yang terakhir untuk router, Lain. Setelah itu node Alice dan Mika disambungkan dengan switch yang sama (swicth 1), lalu Chisa disambung switch 2, kemudian Knights dan Eiri tersambung ke switch yang sama juga (switch 3)   
Lalu, router Lain disambungkan dengan NAT agar bisa mengakses internet yang kemudian router lain disambungkan ke semua switch.   
Berikutnya, setting IP dengan IP Prefix untuk kelompok kami yaitu 192.219.x.x   
Lakukan setting di Router Lain untuk setiap eth nya, eth 0 tersambung ke NAT, eth1 tersambung ke ip 192.219.1.1, eth2 tersambung ke ip 192.219.2.1, eth
