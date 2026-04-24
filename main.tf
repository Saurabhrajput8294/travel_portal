provider "aws" {
  region = "ap-south-1"
}

variable "ec2_ip" {}

resource "null_resource" "deploy" {

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("multiOS-key.pem")
    host        = var.ec2_ip
  }

  provisioner "remote-exec" {
    inline = [

      # Install Docker (Ubuntu)
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",

      # Add user to docker group
      "sudo usermod -aG docker ubuntu",

      # Stop and remove old container
      "sudo docker stop portfolio || true",
      "sudo docker rm portfolio || true",

      # Pull latest image
      "sudo docker pull prakharvs/portfolio:latest",

      # Run container
      "sudo docker run -d -p 80:80 --name portfolio prakharvs/portfolio:latest"
    ]
  }
}