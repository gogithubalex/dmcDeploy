
resource "aws_instance" "front" {
  instance_type = "m4.large"
  depends_on = ["aws_instance.rest"]

  # Lookup the correct AMI based on the region
  # define what aim to launch
  ami = "${lookup(var.frontSHIB, var.aws_region)}"
  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #

 key_name = "${var.key_name_front}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.sg_front.name}"]

  # We run a remote provisioner on the instance after creating it.
  # in this case will be a shell but can be chef




provisioner "remote-exec"{

        inline = [
        "echo 'export AWS_ACCESS_KEY_ID=${var.access_key}' >> /tmp/profile",
        "echo 'export AWS_SECRET_ACCESS_KEY=${var.secret_key}' >> /tmp/profile",
        "echo 'export s3_bucket=${var.cert-web-bucket}' >> /tmp/profile",
        "echo 'export dump_location=${var.sp_cert_location}' >> /tmp/profile",
        "echo 'export dump_location1=${var.sp_key_location}' >> /tmp/profile",
        "echo 'export dump_location2=${var.inc-md-cert_location}' >> /tmp/profile",
        "sudo bash -c 'cat /tmp/profile >> /etc/profile' ",
        "source /etc/profile" ,
        "aws s3 cp s3://$s3_bucket/sp-cert.pem $dump_location",
        "aws s3 cp s3://$s3_bucket/sp-key.pem $dump_location1",
        "aws s3 cp s3://$s3_bucket/inc-md-cert.pem $dump_location2"
        ]

        connection {
        user = "ec2-user"
        key_file  = "${var.key_full_path_front}"

    }
}





provisioner "file" {
        source = "deployMe_front.sh"
        destination = "/tmp/script.sh"

       connection {
        user = "ec2-user"
        key_file  = "${var.key_full_path_front}"
    }
}





provisioner "remote-exec"{

        inline = [
        "echo 'export release=${var.release}' >> /tmp/profile",
        "echo 'export Restip=${var.restLb}' >> /tmp/profile",
        "echo 'export serverURL=${var.serverURL}' >> /tmp/profile",
        "echo 'export restIP=${aws_instance.rest.private_ip}' >> /tmp/profile",
        "echo 'export loglevel=${var.loglevel}' >> /tmp/profile",
        "echo 'export commit_front=${var.commit_front}' >> /tmp/profile",
        "sudo bash -c 'cat /tmp/profile >> /etc/profile' ",
        "source /etc/profile" ,
        "chmod +x /tmp/script.sh",
        "cd /tmp",
        "bash -x script.sh 2>&1 | tee out.log"

        ]

        connection {
        user = "ec2-user"
        key_file  = "${var.key_full_path_front}"

    }
}

  #Instance tags -- name the vm in amazon to find easier
  tags {
    Name = "${var.stackPrefix}DMC-front"
    }


    provisioner "local-exec" {
          command = "scp -oStrictHostKeyChecking=no -i ${var.key_full_path_front} ec2-user@${aws_instance.front.public_ip}:/home/ec2-user/frontSanityTest.log ."
  }


}
