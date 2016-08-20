VBoxManage convertfromraw guixsd-usb-install-0.11.0.x86_64-linux guixsd_boot.vdi
--format vdi

add as storage in vbox

network
  ip link set enp0s3 up
  dhclient enp0s3
  ping jeaye.com
