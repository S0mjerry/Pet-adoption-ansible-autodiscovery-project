locals {
  ansible_user_data = <<-EOF
#!/bin/bash

# update instance and install ansible
sudo yum update -y
sudo dnf install -y ansible-core
sudo yum install python-pip -y
sudo -E pip3 install pexpect

# install wget, unzip, aws cli
sudo yum install wget -y
sudo yum install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo ln -svf /usr/local/bin/aws /usr/bin/aws
sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'

# configuring aws cli on our instance
sudo su -c "aws configure set aws_access_key_id ${aws_iam_access_key.user-access-key.id}" ec2-user
sudo su -c "aws configure set aws_secret_access_key ${aws_iam_access_key.user-access-key.secret}" ec2-user
sudo su -c "aws configure set default.region eu-west-3" ec2-user
sudo su -c "aws configure set default.output text" ec2-user

# setting credentials as environment variable on our instance
export AWS_ACCESS_KEY_ID=${aws_iam_access_key.user-access-key.id}
export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.user-access-key.secret}

# copying files from local machines to ansible server
sudo echo "${file(var.stage-playbook)}" >> /etc/ansible/stage-playbook.yml
sudo echo "${file(var.prod-playbook)}" >> /etc/ansible/prod-playbook.yml
sudo echo "${file(var.stage-bash-script)}" >> /etc/ansible/stage-bash-script.sh
sudo echo "${file(var.prod-bash-script)}" >> /etc/ansible/prod-bash-script.sh
sudo echo "${file(var.stage-trigger)}" >> /etc/ansible/stage-trigger.yml
sudo echo "${file(var.prod-trigger)}" >> /etc/ansible/prod-trigger.yml
sudo echo "${file(var.password)}" >> /etc/ansible/password.yml
sudo echo "${var.private-key}" >> /etc/ansible/key.pem
sudo bash -c 'echo "NEXUS_IP: ${var.nexus-server-ip}:8085" > /etc/ansible/ansible_vars_file.yml'

# pass.txt
echo 'admin123' > /etc/ansible/pass.txt
ansible-vault encrypt --vault-password-file /etc/ansible/pass.txt /etc/ansible/stage-playbook.yml
ansible-vault encrypt --vault-password-file /etc/ansible/pass.txt /etc/ansible/prod-playbook.yml
rm -rvf /etc/ansible/pass.txt

# giving the right permission to the files
sudo chown -R ec2-user:ec2-user /etc/ansible
sudo chmod 400 /etc/ansible/key.pem
sudo chmod 755 /etc/ansible/stage-bash-script.sh
sudo chmod 755 /etc/ansible/prod-bash-script.sh

#creating crontab to execute auto discovery script
echo "*/5 * * * * ec2-user sh /etc/ansible/stage-bash-script.sh" > /etc/crontab
echo "*/5 * * * * ec2-user sh /etc/ansible/prod-bash-script.sh" >> /etc/crontab

# adding newrelic agent to ansible server
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo  NEW_RELIC_API_KEY=NRAK-BG9JS0ABQS0C3VWQZNG2GYVYLSC NEW_RELIC_ACCOUNT_ID=4092157 NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -y
sudo hostnamectl set-hostname Ansible 

EOF
}