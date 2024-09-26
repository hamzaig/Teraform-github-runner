# Specify the AWS provider and region
provider "aws" {
  region = "us-east-1"  # Replace with your preferred region
}

# Reference your existing EC2 instance by its ID
data "aws_instance" "existing_runner" {
  instance_id = "i-0f9a4b42e55a8c1df"  # Replace with your EC2 instance ID
}

resource "null_resource" "github_runner_setup" {
  # Connect to your EC2 instance via SSH
  connection {
    type        = "ssh"
    host        = data.aws_instance.existing_runner.public_ip
    user        = "ubuntu"  # For Ubuntu, default user is 'ubuntu'
    private_key = file("${path.module}/moonsys-pvt-ltd.pem")  # Use relative path for the key
  }

  # Provisioner to install and configure GitHub Runner
  provisioner "remote-exec" {
    inline = [
      # Download and extract GitHub Actions runner
      "mkdir actions-runner-gvr-node && cd actions-runner-gvr-node",

      # Download and extract GitHub Actions runner
      "curl -o actions-runner-linux-x64-2.319.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz",
      "tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz",

      # Configure and start GitHub Actions runner
      "./config.sh --unattended --url https://github.com/${var.github_owner}/${var.github_repo} --token ${var.github_repo_token}",
      "sudo ./svc.sh install",
      "sudo ./svc.sh start"
    ]
  }

  # Ensure that the public IP is correct
  triggers = {
    runner_ip = data.aws_instance.existing_runner.public_ip
  }
}

# Outputs the public IP for debugging purposes
output "instance_public_ip" {
  value = data.aws_instance.existing_runner.public_ip
}