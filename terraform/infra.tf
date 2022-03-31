
provider "aws" {
  region  = "us-east-2"
  access_key = ""
  secret_key = " "
}

#### VPC #############
resource "aws_vpc" "teeravpc"{
    cidr_block ="10.0.0.0/16"
    tags = {
        Name="terravpc"
    }

}

#######Internet Gateway########
resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.teeravpc.id

    tags ={
        Name="internet gateway"
    }
}


#####Nat GateWay #######

resource "aws_eip" "nat_gateway" {
  vpc = true
}

 resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gateway.id
   subnet_id     = aws_subnet.public_subnet1.id

  tags = {
     Name = "gw NAT"
   }
 }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.example]
# }

###### Subnet########
######Public Subnet 1########
resource "aws_subnet" "public_subnet1" {
 vpc_id = aws_vpc.teeravpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet1"
  }
}
#######Route Table#######
resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.teeravpc.id

  route = []

  tags = {
    Name = "public route table1"
  }
}
resource "aws_route" "public_r1" {
  route_table_id            = aws_route_table.public_rt1.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                =aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.public_rt1]
}
#######Security Group########


resource "aws_security_group" "terraform-sg-ps1" {
  vpc_id = aws_vpc.teeravpc.id

  ingress {
    protocol  = -1 #All trafic
    self      = true
   
    from_port = 0 # All ports
    to_port   = 0 #All ports
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = null
    security_groups = null
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = null
    security_groups = null

  }
}
#####Route table Association for public-subnet1#######
resource "aws_route_table_association" "public_sb_rts1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt1.id
  
}

######Public Subnet 2########
resource "aws_subnet" "public_subnet2" {
 vpc_id = aws_vpc.teeravpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet2"
  }
}
#######Route Table#######
resource "aws_route_table" "public_rt2" {
  vpc_id = aws_vpc.teeravpc.id

  route = []

  tags = {
    Name = "public route table pr2"
  }
}
resource "aws_route" "public_route2" {
  route_table_id            = aws_route_table.public_rt2.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                =aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.public_rt2]
  
}
#######Security Group########


resource "aws_security_group" "terraform-sg-ps2" {
  vpc_id = aws_vpc.teeravpc.id

  ingress {
    protocol  = -1 #All trafic
    self      = true
   
    from_port = 0 # All ports
    to_port   = 0 #All ports
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = null
    security_groups = null
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = null
    security_groups = null

  }
  tags = {
    "Name" = "sg-ps2"
  }
}
#####Route table Association for public-subnet2#######
resource "aws_route_table_association" "public_sb_rts2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt2.id
  
}


######EC2 Instance########
resource "aws_instance" "webserver" {
  ami                         = "ami-0fb653ca2d3203ac1"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "keypair"
  subnet_id                   = aws_subnet.public_subnet1.id
   vpc_security_group_ids      = [aws_security_group.terraform-sg-ps1.id]


  tags = {
    "Name" = "WebServer"
  }
}

resource "aws_instance" "Bootstrap" {
  ami                         = "ami-0fb653ca2d3203ac1"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "keypair"
  subnet_id                   = aws_subnet.public_subnet2.id
  vpc_security_group_ids      =  [aws_security_group.terraform-sg-ps2.id]

  tags = {
    "Name" = "BootServer"
  }
}


#########Private Subnet######
resource "aws_subnet" "private_subnet1" {
 vpc_id = aws_vpc.teeravpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet1"
  }
}

#######Route Table For private Subnet 1##########
resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.teeravpc.id

  route = []

  tags = {
    Name = "private route table1"
  }
}
resource "aws_route" "private_r1" {
  route_table_id            = aws_route_table.private_rt1.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                =aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.private_rt1]

  
}
#######Security Group########


resource "aws_security_group" "terraformprivate1-sg" {
  vpc_id = aws_vpc.teeravpc.id

  ingress {
    protocol  = "tcp" #All trafic
    self      = true
   
    from_port = 8000 # All ports
    to_port   = 8000 #All ports
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = null
    security_groups = null
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = null
    security_groups = null

    

  }
}
#####Route table Association#######
resource "aws_route_table_association" "private_sb_rts1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt1.id
  
}

#########Private Subnet2######
resource "aws_subnet" "private_subnet2" {
 vpc_id = aws_vpc.teeravpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet2"
  }
}

#######Route Table For Private Subnet 2#######
resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.teeravpc.id

  route = []

  tags = {
    Name = "private route table2"
  }
}
resource "aws_route" "private_r2" {
  route_table_id            = aws_route_table.private_rt2.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                =aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.private_rt2]

  
}
#######Security Group########



resource "aws_security_group" "terraformprivate2-sg" {
  vpc_id = aws_vpc.teeravpc.id

  ingress {
    protocol  = "tcp" #All trafic
    self      = true
   
    from_port = 8000 # All ports
    to_port   = 8000 #All ports
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = null
    security_groups = null
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = null
    security_groups = null
  }
    tags ={
      Name ="private-sg2"
    }

  
}
#####Route table Association For Private Subnet 2#######
resource "aws_route_table_association" "private_sb_rts2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt2.id
 
}


#########Private Subnet2######
resource "aws_subnet" "private_subnet3" {
 vpc_id = aws_vpc.teeravpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet3"
  }
}

#


#####Application Server######
######EC2 Instance########
resource "aws_instance" "ApplicationServer" {
  ami                         = "ami-0fb653ca2d3203ac1"
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = "keypair"
  subnet_id                   = aws_subnet.private_subnet1.id
  vpc_security_group_ids      = [aws_security_group.terraformprivate1-sg.id]

  tags = {
    "Name" = "ApplicationServer"
  }
}



resource "aws_security_group" "rds-sg" {
  vpc_id = aws_vpc.teeravpc.id

  ingress {
    protocol  = "tcp" #All trafic
    self      = true
   
    from_port = 3306 
    to_port   = 3306 
    cidr_blocks = [ "0.0.0.0/0" ]
    prefix_list_ids = null
    security_groups = null
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = null
    security_groups = null
  }
    tags ={
      Name ="rds-sg"
    }

  
}

resource "aws_db_subnet_group" "rds-subnet-group" {
  
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "chatapp" {
   #rds_instance_identifier = "terraform-mysql"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "chatapp"
  username             = "admin"
  password             = "admin123"
  
  #security_group_names = [aws_security_group.rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds-subnet-group.id
  vpc_security_group_ids    = [aws_security_group.rds-sg.id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
 
}
