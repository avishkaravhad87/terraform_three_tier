
resource "aws_vpc" "vpc_first" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "first_vpc"
  }
}


resource "aws_subnet" "public_sub" {
    
vpc_id = aws_vpc.vpc_first.id
 cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a"
map_public_ip_on_launch = true 
}

resource "aws_internet_gateway" "igt" {
   vpc_id = aws_vpc.vpc_first.id
}

resource "aws_route_table" "route_table"{
  vpc_id = aws_vpc.vpc_first.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igt.id
  }
}

resource "aws_route_table_association" "route_table_asso" {
  subnet_id = aws_subnet.public_sub.id
  route_table_id = aws_route_table.route_table.id
}
  
resource "aws_subnet" "private_sub_1" {
  vpc_id = aws_vpc.vpc_first.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  }

  resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.vpc_first.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = false
    
  }

  resource "aws_eip" "elastic_ip" {
    domain = "vpc"
    
    }

    resource "aws_nat_gateway" "nat" {
      allocation_id = aws_eip.elastic_ip.id
      subnet_id = aws_subnet.public_sub.id
      
    }

   resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc_first.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

    
    resource "aws_route_table_association" "private_assosication_table" {
      subnet_id = aws_subnet.private_sub_1.id
      route_table_id = aws_route_table.rt_private.id

      
    }

  resource "aws_route_table_association" "private_assosication_table-2" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.rt_private.id
    
  }

  resource "aws_security_group" "ssh" {
    name = "allow_ssh"
    description = "AllowSSHaccess"
    vpc_id = aws_vpc.vpc_first.id
    
  }

  resource "aws_vpc_security_group_ingress_rule" "inbound-1" {
    security_group_id = aws_security_group.ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22

  }

  resource "aws_vpc_security_group_ingress_rule" "inbound-2" {
    security_group_id = aws_security_group.ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 8080
    ip_protocol = "tcp"
    to_port = 8080
    
  }
resource "aws_vpc_security_group_ingress_rule" "inbound-3" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
  
}
resource "aws_vpc_security_group_ingress_rule" "inbound-4" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 3306
  ip_protocol = "tcp"
  to_port = 3306
  
}

  
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
  
}

resource "aws_network_interface" "network" {
  subnet_id = aws_subnet.public_sub.id
  private_ip = "10.0.1.100"

}
resource "aws_network_interface_sg_attachment" "sg2" {
  security_group_id = aws_security_group.ssh.id
  network_interface_id = aws_instance.vm_1.primary_network_interface_id
  
}

resource "aws_instance" "vm_1" {
  ami = "ami-01b799c439fd5516a"
  instance_type = "t2.micro"
  key_name = "3-tier"
  network_interface {
    network_interface_id = aws_network_interface.network.id
    device_index = 0
  }
  tags = {
    Name = "NGlx"
  }
}

resource "aws_network_interface" "private_network" {
  subnet_id = aws_subnet.private_sub_1.id
  private_ip = "10.0.20.100"
  
}

resource "aws_instance" "private_1" {
  ami = "ami-01b799c439fd5516a"
  instance_type = "t2.micro"
  key_name = "3-tier"
  network_interface {
    network_interface_id = aws_network_interface.private_network.id
    device_index = 0
  }
  tags = {
    name = "private-1-tomcat"
  }

}
  
  resource "aws_network_interface_sg_attachment" "sg-private" {
    security_group_id = aws_security_group.ssh.id
    network_interface_id = aws_instance.private_1.primary_network_interface_id
    
  }

  resource "aws_network_interface" "private_network-2" {
    subnet_id = aws_subnet.private_subnet_2.id
    private_ip  = "10.0.30.100"

  }

  resource "aws_instance" "private-2" {
    ami = "ami-01b799c439fd5516a"
    instance_type = "t2.micro"
    key_name = "3-tier"
    network_interface {
      network_interface_id = aws_network_interface.private_network-2.id
      device_index = 0
    }
    tags = {
      name = "database"
    }
  }

  resource "aws_network_interface_sg_attachment" "sg-private-2" {
    security_group_id = aws_security_group.ssh.id
    network_interface_id = aws_instance.private-2.primary_network_interface_id
    
  }

  resource "aws_db_subnet_group" "db_subnet" {
    name = "db_subnet"
    subnet_ids = [aws_subnet.private_sub_1.id,aws_subnet.private_subnet_2.id]
  }

  resource "aws_db_instance" "rds" {
    allocated_storage = 20
    db_name = "student"
    engine = "mariadb"
    engine_version = "10.11.6"
    username = "admin"
    password = "passwd123"
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_subnet_group_name = aws_db_subnet_group.db_subnet.name
    vpc_security_group_ids = [aws_security_group.ssh.id]
    tags = {
      name = "student1"
    }
    
  }

