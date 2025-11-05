sudo usermod -aG input rsh

groups rsh

echo 'KERNEL=="uinput", GROUP="input", MODE="0660"' | sudo tee /etc/udev/rules.d/90-uinput.rules

cat /etc/udev/rules.d/90-uinput.rules

sudo udevadm control --reload-rules
sudo udevadm trigger

ls -l /dev/uinput

sudo cp ~/.config/kmonad/kmonad.service /usr/lib/systemd/system/kmonad.service

sudo mkdir -p /etc/kmonad >/dev/null

sudo cp ~/.config/kmonad/config.kbd /etc/kmonad/config.kbd

sudo systemctl disable kmonad
sudo systemctl enable --now kmonad

sudo systemctl start kmonad
sudo systemctl daemon-reload
