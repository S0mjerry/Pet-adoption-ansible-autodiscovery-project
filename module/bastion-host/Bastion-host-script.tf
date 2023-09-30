locals {
 bastion-host_user_data = <<-EOF
#!/bin/bash
echo "${var.private_keypair_path}" >> /home/ec2-user/ET2PACAAD
chmod 400 /home/ec2-user/ET2PACAAD
chown ec2-user:ec2-user /home/ec2-user/ET2PACAAD
sudo hostnamectl set-hostname Bastion
EOF
}
