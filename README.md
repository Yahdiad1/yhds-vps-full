# YHDS VPS Full Menu

Skrip ini menyediakan menu VPS lengkap dengan:

- SSH, UDP-Custom, WS, Trojan, V2Ray  
- UDP-Custom port 1–65535  
- Auto-install dependencies  
- Bisa dijalankan dengan perintah `menu`  
- Bisa dijalankan di screen  

---

## Cara Install

1. Login ke VPS sebagai root
2. Download skrip menu:

```bash
wget -O /usr/local/bin/menu https://raw.githubusercontent.com/YYahdiad1/yhds-vps-full/main/menu
chmod +x /usr/local/bin/menu

##- Bisa dijalankan dengan perintah `menu`  
- Bisa dijalankan di screen

3. Jalankan menu:



menu

4. (Opsional) Jalankan di screen agar tetap hidup:



screen -dmS yhds-menu menu
screen -r yhds-menu
