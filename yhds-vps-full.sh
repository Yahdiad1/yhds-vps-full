cat >/usr/local/bin/menu <<'EOF'
#!/bin/bash
# YHDS VPS Menu - Bisa dipanggil dengan 'menu'

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Script harus dijalankan sebagai root!${NC}"
   exit 1
fi

apt update -y && apt install -y wget curl unzip bzip2 screen git jq lsof netcat
mkdir -p /etc/yhds /usr/local/bin /etc/udp-custom

if [ ! -f /usr/local/bin/udp-custom ]; then
    echo -e "${BLUE}Menginstall UDP-Custom...${NC}"
    wget -O /usr/local/bin/udp-custom "https://raw.githubusercontent.com/noobconner21/UDP-Custom-Script/main/udp-custom-linux-amd64"
    chmod +x /usr/local/bin/udp-custom
fi

cat >/etc/udp-custom/server.json <<EOL
{
    "port_start": 1,
    "port_end": 65535,
    "mode": "auto"
}
EOL

cat >/etc/systemd/system/udp-custom.service <<EOL
[Unit]
Description=UDP-Custom Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/udp-custom server --config /etc/udp-custom/server.json
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable udp-custom
systemctl restart udp-custom

create_user() {
    read -p "Masukkan username: " USER
    read -p "Masukkan password: " PASS
    read -p "Masukkan hari expired: " EXPIRE
    EXPIRE_DATE=$(date -d "+$EXPIRE days" +"%Y-%m-%d")
    echo "$USER,$PASS,$EXPIRE_DATE" >> /etc/yhds/users.csv
    echo -e "${GREEN}Akun berhasil dibuat!${NC}"
    echo "==============================="
    echo "Username : $USER"
    echo "Password : $PASS"
    echo "Expired  : $EXPIRE_DATE"
    echo "==============================="
}

menu_loop() {
while true; do
clear
echo -e "${BLUE}===== YHDS VPS MENU =====${NC}"
echo "1) Create SSH Account"
echo "2) Create UDP-Custom Account"
echo "3) Create WS Account"
echo "4) Create Trojan Account"
echo "5) Create V2Ray Account"
echo "6) List Users"
echo "7) Remove User"
echo "8) Restart UDP-Custom Service"
echo "9) Check UDP-Custom Status"
echo "10) Check Logs"
echo "11) Auto Update Script"
echo "12) Exit"
echo -n "Pilih menu [1-12]: "
read MENU
case $MENU in
    1) create_user ;;
    2) create_user ;;
    3) create_user ;;
    4) create_user ;;
    5) create_user ;;
    6) cat /etc/yhds/users.csv ;;
    7) read -p "Masukkan username yang akan dihapus: " UDEL
       sed -i "/^$UDEL,/d" /etc/yhds/users.csv
       echo -e "${GREEN}User $UDEL dihapus${NC}" ;;
    8) systemctl restart udp-custom
       echo -e "${GREEN}UDP-Custom direstart${NC}" ;;
    9) systemctl status udp-custom --no-pager ;;
    10) journalctl -u udp-custom -n 50 --no-pager ;;
    11) wget -O /usr/local/bin/menu "$0" && chmod +x /usr/local/bin/menu
        echo -e "${GREEN}Script updated!${NC}" ;;
    12) exit ;;
    *) echo -e "${RED}Pilihan salah!${NC}" ;;
esac
read -n1 -r -p "Tekan sembarang tombol untuk kembali ke menu..."
done
}

menu_loop
EOF
chmod +x /usr/local/bin/menu
echo -e "\nMenu siap dijalankan dengan ketik: menu"
