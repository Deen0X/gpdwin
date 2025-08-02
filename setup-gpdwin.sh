#!/bin/bash

# 🧠 Variables
USER_NAME=$(whoami)
HOME_DIR=$(eval echo ~$USER_NAME)

echo "🧩 [0] Creando script de gestión automática de pantallas..."
cat << 'EOF' > $HOME_DIR/monitor-watch.sh
#!/bin/bash
export DISPLAY=:0

if xrandr | grep "HDMI-1 connected"; then
    xrandr --output HDMI-1 --mode 1920x1080 --primary --output DSI-1 --off
else
    xrandr --output DSI-1 --auto --rotate right --primary
fi
EOF

echo "🔧 [1] Instalando y habilitando servidor SSH..."
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

echo "🔽 [2] Descargando e instalando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo apt install -y ./chrome.deb
rm chrome.deb
echo "✅ Google Chrome instalado correctamente."

echo "🌐 [3] Instalando Chrome Remote Desktop..."
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb -O /tmp/chrome-remote-desktop.deb
sudo apt install -y /tmp/chrome-remote-desktop.deb
rm /tmp/chrome-remote-desktop.deb

echo "🖥️ [4] Instalando gestor de pantallas (Arandr)..."
sudo apt install -y arandr

chmod +x $HOME_DIR/monitor-watch.sh

echo "🔁 [5] Automatizando gestión de pantallas con cron..."
(crontab -l 2>/dev/null; echo "* * * * * $HOME_DIR/monitor-watch.sh") | crontab -

echo "🔄 [6] Creando alias para rotar pantalla integrada..."
echo "alias rotate='xrandr --output DSI-1 --rotate right'" >> $HOME_DIR/.bashrc

echo "🎮 [7] Instalando RetroPie..."
sudo apt install -y git dialog
cd $HOME_DIR
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
sudo ./retropie_setup.sh

echo ""
read -p "🕹️ ¿Quieres que RetroPie se inicie automáticamente al arrancar? (s/n): " AUTO_RETRO

if [[ "$AUTO_RETRO" == "s" ]]; then
    echo "🧠 Configurando RetroPie como sesión por defecto..."
    sudo bash -c "echo '[Seat:*]' > /etc/lightdm/lightdm.conf"
    sudo bash -c "echo 'autologin-user=$USER_NAME' >> /etc/lightdm/lightdm.conf"
    sudo bash -c "echo 'autologin-session=retropie' >> /etc/lightdm/lightdm.conf"
else
    echo "🖥️ Manteniendo escritorio gráfico como inicio por defecto."
    echo "🕹️ Creando acceso directo para RetroPie en el escritorio..."

    cat << EOF > $HOME_DIR/Desktop/RetroPie.desktop
[Desktop Entry]
Name=RetroPie
Comment=Lanzar RetroPie Setup
Exec=sudo $HOME_DIR/RetroPie-Setup/retropie_setup.sh
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Game;
EOF

    chmod +x $HOME_DIR/Desktop/RetroPie.desktop
fi

echo ""
read -p "🔐 ¿Deseas cambiar la contraseña del usuario '$USER_NAME'? (s/n): " CHANGE_PASS

if [[ "$CHANGE_PASS" == "s" ]]; then
    echo "🔑 Cambiando contraseña..."
    passwd $USER_NAME
fi

echo "✅ Configuración completa. Puedes reiniciar el sistema si lo deseas."
