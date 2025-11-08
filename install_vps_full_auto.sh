#!/bin/bash
# install_vps_full_auto.sh - YHDS VPS Full Installer (Auto Update Safe)

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Pastikan root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Script harus dijalankan sebagai root!${NC}"
   exit 1
fi

echo -e "${BLUE}Updating system & installing dependencies...${NC}"
apt update -y && apt upgrade -y
apt install -y wget curl unzip bzip2 screen git jq lsof ufw netcat-openbsd

# Buat folder config
mkdir -p /etc/yhds
mkdir -p /etc/udp-custom
mkdir -p /usr/local/bin

# Setup firewall
echo -e "${BLUE}Configuring firewall...${NC}"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80,443/tcp
ufw allow proto udp from any to any
ufw --force enable

# ===========================================================
# Stop & kill old screen
# ===========================================================
echo -e "${BLUE}Cleaning old yhds-menu screens...${NC}"
for pid in $(screen -ls | grep yhds-menu | awk '{print $1}'); do
    screen -S $pid -X quit
done

# ===========================================================
# Install/Update UDP-Custom x86_64
# ===========================================================
echo -e "${BLUE}Installing UDP-Custom x86_64...${NC}"
systemctl stop udp-custom 2>/dev/null
wget -O /usr/local/bin/udp-custom "https://raw.githubusercontent.com/noobconner21/UDP-Custom-Script/main/udp-custom-linux-amd64" -q --show-progress
chmod +x /usr/local/bin/udp-custom

cat >/etc/udp-custom/server.json <<EOL
{
    "port_start": 1,
    "port_end": 65535,
    "mode": "auto"
}
EOL

cat >/etc/systemd/system/udp-custom.service <<EOL
[Unit]
Description=UDP-Custom Service (akunssh)
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
echo -e "${GREEN}UDP-Custom terpasang & service aktif${NC}"

# ===========================================================
# Create user function
# ===========================================================
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

check_udp() {
    systemctl is-active --quiet udp-custom
    if [ $? -ne 0 ]; then
        echo -e "${RED}UDP-Custom service tidak aktif!${NC}"
        return
    fi
    echo -e "${GREEN}UDP-Custom service aktif${NC}"
    echo -e "${BLUE}Port UDP listen (50 pertama):${NC}"
    ss -anu | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort -n | uniq | head -50
}

test_udp_menu() {
    echo -e "${BLUE}Testing UDP ports 1-65535 yang aktif...${NC}"
    LISTEN_PORTS=$(ss -anu | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort -n | uniq)
    if [ -z "$LISTEN_PORTS" ]; then
        echo -e "${RED}Tidak ada port UDP listen!${NC}"
        return
    fi
    echo -e "${GREEN}Port UDP aktif:${NC}"
    echo "$LISTEN_PORTS" | head -50
}

# ===========================================================
# Jalankan menu loop
# ===========================================================
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
echo "9) Check UDP-Custom Status & Ports"
echo "10) Check Logs"
echo "11) Test UDP Ports"
echo "12) Update UDP-Custom Binary"
echo "13) Exit"
echo -n "Pilih menu [1-13]: "
read MENU
case $MENU in
    1|2|3|4|5) create_user ;;
    6) cat /etc/yhds/users.csv ;;
    7) read -p "Masukkan username yang akan dihapus: " UDEL
       sed -i "/^$UDEL,/d" /etc/yhds/users.csv
       echo -e "${GREEN}User $UDEL dihapus${NC}" ;;
    8) systemctl restart udp-custom
       echo -e "${GREEN}UDP-Custom direstart${NC}" ;;
    9) check_udp ;;
    10) journalctl -u udp-custom -n 50 --no-pager ;;
    11) test_udp_menu ;;
    12)
       systemctl stop udp-custom
       wget -O /usr/local/bin/udp-custom "https://raw.githubusercontent.com/noobconner21/UDP-Custom-Script/main/udp-custom-linux-amd64" -q --show-progress
       chmod +x /usr/local/bin/udp-custom
       systemctl restart udp-custom
       echo -e "${GREEN}UDP-Custom diperbarui${NC}" ;;
    13) exit ;;
    *) echo -e "${RED}Pilihan salah!${NC}" ;;
esac
read -n1 -r -p "Tekan sembarang tombol untuk kembali ke menu..."
done
}

# ===========================================================
# Jalankan menu di screen baru
# ===========================================================
screen -dmS yhds-menu bash -c "menu_loop"
echo -e "${GREEN}Menu YHDS VPS sudah berjalan di screen 'yhds-menu'. Gunakan: screen -r yhds-menu${NC}"
