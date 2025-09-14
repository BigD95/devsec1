provider "aws" {
  region = "eu-west-3" # Paris
}

# 🔑 Ta clé publique SSH
resource "aws_key_pair" "my_key" {
  key_name   = "my-ssh-key"
  public_key = file("./ssh/id_rsa.pub")
}

# 🔒 Security Group pour SSH + autres ports
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Autoriser SSH et autres ports depuis mon IP"
  vpc_id      = "vpc-0af16319e6c248517" # Remplace par ton VPC ID si besoin

  # SSH
  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Remplace par ton IP publique ou All
  }

  # Port 8080
  ingress {
    description = "Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 9000
  ingress {
    description = "Port 9000"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 50000
  ingress {
    description = "Port 50000"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Sortie (egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔎 AMI Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# 🖥️ Instance EC2 avec script d’installation
resource "aws_instance" "ubuntu_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large" # 2 vCPU, 8 Go RAM

  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  # Sans ce bloc de connexion impossible de copier le ficher
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./ssh/id_rsa")
      host        = self.public_ip
    }

  # 🔹 Provisioner pour copier le script et docker-compose.yml
  provisioner "file" {
    source      = "./setup.sh"
    destination = "/home/ubuntu/setup.sh"
  }

  provisioner "file" {
    source      = "./docker-compose/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  # Copier dockerfile.agent
  provisioner "file" {
    source      = "./docker-compose/Dockerfile"
    destination = "/home/ubuntu/Dockerfile"
  }

  # 🔹 Provisioner pour exécuter le script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/setup.sh",
      "sudo /home/ubuntu/setup.sh"
    ]

  }

  tags = {
    Name = "Ubuntu-Server-Docker-Jenkins"
  }
}

# ➤ Afficher l’IP publique après déploiement
output "public_ip" {
  value = aws_instance.ubuntu_server.public_ip
}

