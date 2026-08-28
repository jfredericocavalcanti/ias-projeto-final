data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-server"
  }

  provisioner "local-exec" {
    working_dir = path.module
    interpreter = ["/bin/bash", "-c"]

    command = <<-EOT
      set -e
      echo "[Terraform] EC2 criada: ${self.public_ip}"
      mkdir -p ../ansible/inventory
      cat > ../ansible/inventory/hosts.yml <<EOF
all:
  hosts:
    app_server:
      ansible_host: ${self.public_ip}
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${pathexpand(var.private_key_path)}
      ansible_python_interpreter: /usr/bin/python3
EOF
      chmod 600 ../ansible/inventory/hosts.yml
      ../scripts/deploy-ansible.sh
    EOT
  }
}
