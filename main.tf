# Configure the DigitalOcean Provider
provider "digitalocean" {}

# Create a new Web Droplet in the fra1 region
resource "digitalocean_droplet" "gitlab" {
  image  = "ubuntu-16-04-x64"
  name   = "gitlab"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = ["b8:18:ea:a4:49:f3:72:06:d5:e3:06:55:4f:38:9b:4d"]
  user_data = <<-EOF
    #!/bin/bash
    # add non privileged user
    export PASS=$(openssl passwd -1 labuserSecret)
    export USER=labuser
    useradd -p $PASS -m $USER
    usermod -aG sudo $USER
    # Disable password authentication
    #
    sudo grep -q "ChallengeResponseAuthentication" /etc/ssh/sshd_config && sed -i "/^[^#]*ChallengeResponseAuthentication[[:space:]]yes.*/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config || echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
    #
    sudo grep -q "^[^#]*PasswordAuthentication" /etc/ssh/sshd_config && sed -i "/^[^#]*PasswordAuthentication[[:space:]]yes/c\PasswordAuthentication no" /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
    #
    sudo grep -q "^[^#]*PermitRootLogin" /etc/ssh/sshd_config && sed -i "/^[^#]*PermitRootLogin[[:space:]]yes/c\PermitRootLogin no" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
    #
    sudo service ssh restart
    #copy authorized keys
    cp -rf /root/.ssh /home/$USER/.
    chown -R $USER:$USER /home/$USER
    EOF
}
output "web_ip" {
  value = "${digitalocean_droplet.gitlab.ipv4_address}"
}
