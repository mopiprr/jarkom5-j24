# Soal 1
# Cara mengkonfigurasi iptables pada router 'Heiji' agar semua jaringan dapat menagkses internet melalui internet eth0 tanpa menggunakan MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -s 10.1.0.0/20 -j SNAT --to-source $(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Soal 2
# Diminta untuk melakukan drop semua paket masuk TCP kecuali dari port 1744
# Install netcat di Shinichi dan Kogoro
# di Shinichi
iptables -A INPUT -p tcp --dport 1744 -j ACCEPT
iptables -A INPUT -p tcp -j DROP
# iptables -A INPUT -P udp -j DROP masih bingung udp perlu di drop juga atau ga

# Test bisa dilakukan menggunakan netcat
# Shinichi : nc -l -p 1744 (port untuk listen)
# client : nc 10.1.0.131 1744 (netcat ke ip shinchi port 1744)
# coba masukkan text, kalau muncul di shinichi berarti berhasil, kalau tidak ada text berarti ter drop

# Soal 3
# Diminta untuk membatas koneksi SSH semua web server sehinnga hanya bisa diakses Ran
# Install netcat di seluruh webserver dan Ran
# command ini taruh di semua webserver
iptables -A INPUT -p tcp --dport 22 -s 10.1.4.2 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Test dilakukan di Ran dan client lain (contoh kogoro)
# Webserver : nc -l -p 22 (listen port 22 untuk koneksi dari Ran)
# Ran dan client : nc <ip webserver> 22 
# Seharusnya hanya text dari Ran yang masuk ke server tersebut

# Soal 4
# Webserver hanya dapat diakses pada port 80 dan 443 pada
# Senin-Jumat pukul 07.00-19.00
# Selain jam tersebut, drop
iptables -A INPUT -p tcp -m multiport --dports 80,443 \
-m time --timestart 07:00 --timestop 19:00 \
--weekdays Mon,Tue,Wed,Thu,Fri -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j DROP

# Soal 5
# Tambah iptables rule untuk subnet Haibara (10.1.8.0/21)
# agar dapat diakses hari sabtu-minggu tanpa batasan waktu
# Taroh diatas rule soal no 4
iptables -A INPUT -s 10.1.8.0/21 -p tcp -m multiport --dports 80,443 \
-m time --weekdays Sat,Sun -j ACCEPT

# Soal 6
# Akses ke web server melalui port 80 dan 443 dilarang pada hari jumat, pukul 11.00-13.00 (maklum jumatan)
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m time --weekdays Fri --timestart 11:00 --timestop 13:00 -j DROP

# Soal 7 (terakhir)

# Soal 8 
# Pilih salah satu subnet, lakukan blokir semua request ICMP (ping) dari luar subnet tersebut
# Subnet yang dipilih A1, block dari source Agasa n Sonoko
# Block traffic from 192.168.1.10 on the interface connected to Agasa
iptables -A INPUT -i eth0 -p all -s 10.1.0.6 -j DROP

# Block traffic from 192.168.1.10 on the interface connected to Sonoko
iptables -A INPUT -i eth1 -p all -s 10.1.0.1 -j DROP

# Masih error

# Soal 9
# limit ping ke web server maksimal 10 ping dalam 1 menit
iptables -N portscan

iptables -A INPUT -m recent --name portscan --update --seconds 60 --hitcount 10 -j DROP
iptables -A FORWARD -m recent --name portscan --update --seconds 60 --hitcount 10 -j DROP

iptables -A INPUT -m recent --name portscan --set -j ACCEPT
iptables -A FORWARD -m recent --name portscan --set -j ACCEPT
# Test : Ping dari client ke webserver