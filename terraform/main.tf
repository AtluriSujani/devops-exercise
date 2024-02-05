resource "aws_instance" "server" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t3a.medium"
  key_name               = "test"
  vpc_security_group_ids = ["sg-0525e251f22e02914"]

  tags = {
    Name = "devops-server"
  }
}
resource "null_resource" "ec2-ssh-connection" {
  provisioner "remote-exec" {

    inline = [
      "sudo snap install docker",
      "sudo docker run --name redis -d -p 6379:6379 redis",
      "git clone https://github.com/AtluriSujani/devops-exercise.git",
      "cd /home/ubuntu/devops-exercise/back",
      "echo ENV REDIS_SERVER ${aws_instance.server.public_ip}:6379 >> Dockerfile",
      "sudo docker build -t back .",
      "sudo docker run --name back -itd -p 4000:4000 back:latest",
      "cd /home/ubuntu/devops-exercise/front",
      "echo ENV BACKEND_API_URL http://${aws_instance.server.public_ip} >> Dockerfile",
      "echo ENV CLIENT_API_URL http://${aws_instance.server.public_ip} >> Dockerfile",
      "sudo docker build -t front .",
      "sudo docker run --name front -itd -p 3000:3000 front:latest"
    ]


    connection {
      host        = aws_instance.server.public_ip
      type        = "ssh"
      port        = 22
      user        = "ubuntu"
      private_key = file("/Users/ravindrasingh/Desktop/test.pem")
      timeout     = "1m"
      agent       = false
    }
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}
