
/*
resource "aws_instance" "activeMq" {
  instance_type = "m4.large"
 

  # Lookup the correct AMI based on the region
  # we specified
   ami = "${lookup(var.aws_amirehl_tom, var.aws_region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #

 key_name = "${var.key_name_activeMq}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.sg_activemq.name}"]

  # We run a remote provisioner on the instance after creating it.
  #this is where we set the env variables





  provisioner "file" {
        source = "deployMe_active.sh"
        destination = "/tmp/script.sh"

       connection {
        user = "ec2-user"
        key_file  = "${var.key_full_path_activeMq}"
    }
    }

  
   provisioner "remote-exec" {
        inline = [
         "echo 'export commit_front=${var.commit_front}' >> /tmp/profile",   
        "sudo bash -c 'cat /tmp/profile >> /etc/profile' ",
        "source /etc/profile" ,
        "chmod +x /tmp/script.sh",
        "cd /tmp",
        "bash -x script.sh 2>&1 | tee out.log"
        ]

      connection {
        user = "ec2-user"
        key_file  = "${var.key_full_path_activeMq}"
    }
}



  #Instance tags
  tags {
    Name = "${var.stackPrefix}DMC-activeMq"
  }
}

*/