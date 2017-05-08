#!/bin/bash

export GITHUB_PAGES="https://radium226.github.io/private-server"

grub_menuentry_index()
{
  declare name="${1}"
  grep -E '^[[:space:]]*menuentry[[:space:]]' '/boot/grub/grub.cfg' | \
  awk '{printf("%s:%s\n", NR -1,  $0);}' | \
  grep "'${name}'" | \
  cut -d':' -f1
}

provision_linux_image()
{
  # We update APT cache and install the latest Linux image
  apt-get -y update
  apt-get -y install "linux-image-generic"

  # We retreive the GRUB menuentry index of Ubuntu
  declare index=$( grub_menuentry_index 'Ubuntu' )

  # And we can update GRUB
  sed -i "s,GRUB_DEFAULT=0,GRUB_DEFAULT=${index},g" '/etc/default/grub'
  update-grub
}


APT_PACKAGES_TO_REMOVE=("bind9") # Because of Kimsufi
APT_PACKAGES_TO_INSTALL=("python-minimal" "wget" "curl") # In order to use Ansible
provision_apt()
{
  apt-get -y update
  #apt-get -y upgrade
  apt-get -y remove "${APT_PACKAGES_TO_REMOVE[@]}"
  apt-get -y install "${APT_PACKAGES_TO_INSTALL[@]}"
}

provision_cloud_init()
{
  apt-get -y update
  apt-get -y install "cloud-init"

  declare temp_folder_path="$( mktemp -d )"
  wget "${GITHUB_PAGES}/cloud.cfg.d.tar.gz" -P "${temp_folder_path}"
  tar xf "${temp_folder_path}/cloud.cfg.d.tar.gz" -C "/etc/cloud/cloud.cfg.d"

  systemctl start clout-init.service
}

MODULES_TO_PROVISION=("linux_image" "apt" "cloud_init")
main()
{
  local module=
  for module in "${MODULES_TO_PROVISION[@]}"; do
    provision_${module}
  done
  reboot
}

main "${@}"
