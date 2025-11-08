# yhds-vps-full
# 🧠 YHDS VPS Full Installer

Installer lengkap untuk server Debian/Ubuntu — mencakup **SSH, WebSocket, Trojan, V2Ray, dan UDP-Custom (port 1–65535)** dengan menu interaktif, auto-update, dan perlindungan firewall otomatis.

---

## ⚙️ Fitur Utama
✅ Instalasi otomatis semua dependency  
✅ UDP-Custom aktif di semua port (1–65535)  
✅ Menu interaktif 1–13  
✅ Auto update binary UDP-Custom  
✅ Bisa test port UDP aktif  
✅ Firewall dasar (UFW) otomatis aktif  
✅ Aman — tidak reboot otomatis  
✅ Kompatibel di VPS arsitektur **x86_64 (AMD64)**  

---

## 🧩 Kompatibilitas
- Debian 10 / 11 / 12  
- Ubuntu 20.04 / 22.04  
- Arsitektur: **x86_64 (AMD64)**  

---

## 🚀 Cara Install
Salin dan jalankan perintah di bawah ini pada VPS baru kamu 👇

```bash
wget -O install_vps_full_custom.sh https://raw.githubusercontent.com/Yahdiad1/yhds-vps-full/main/install_vps_full_custom.sh
chmod +x install_vps_full_custom.sh
screen -S yhds-menu
./install_vps_full_custom.sh

Setelah itu, menu utama akan muncul otomatis.
Gunakan screen agar menu tetap berjalan walau koneksi putus.

Untuk kembali ke menu:

screen -r yhds-menu


---

🧰 Menu Utama

No	Fungsi

1	Create SSH Account
2	Create UDP-Custom Account
3	Create WS Account
4	Create Trojan Account
5	Create V2Ray Account
6	List Users
7	Remove User
8	Restart UDP-Custom
9	Check UDP-Custom Status
10	Check Logs
11	Test UDP Ports
12	Update UDP-Custom Binary
13	Exit



---

🔄 Update UDP-Custom Manual

Jika ingin memperbarui binary UDP-Custom secara manual:

systemctl stop udp-custom
wget -O /usr/local/bin/udp-custom "https://raw.githubusercontent.com/noobconner21/UDP-Custom-Script/main/udp-custom-linux-amd64"
chmod +x /usr/local/bin/udp-custom
systemctl restart udp-custom
