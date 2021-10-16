
resource "aws_key_pair" "slacko-sshkey" {
    key_name = "slacko-app-key"
    public_key = file("${path.module}/files/slacko.pub")
}
resource "aws_instance" "slacko-EC2" {
    ami = data.aws_ami.slacko-app.id
    instance_type = "t2.small"
    subnet_id = data.aws_subnet.subnet_public.id
    associate_public_ip_address = true

    tags = merge(var.tags,{ "Name" = format("%s-slacko-EC2", var.name)},)

    key_name = aws_key_pair.slacko-sshkey.id 
    user_data = file("${path.module}/files/ec2.sh")
}
resource "aws_instance" "mongodb-EC2" {
    ami = data.aws_ami.slacko-app.id
    instance_type = "t2.small"
    subnet_id = data.aws_subnet.subnet_public.id

    tags = merge(var.tags,{ "Name" = format("%s-mongodb-EC2", var.name)},)

    key_name = aws_key_pair.slacko-sshkey.id
    user_data = file("${path.module}/files/mongodb.sh")
}
resource "aws_security_group" "allow-slacko" {
    name = "allow_ssh_http"
    description = "Allow ssh and http port"
    vpc_id = var.vpc_id 

    ingress =[
    {
        description = "Allow SSH"
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    },
    {
        description = "Allow Http"
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]
    egress = [
    {
        description = "Allow all"
        from_port = 1
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]

    tags = merge(var.tags,{ "Name" = format("%s-allow-slacko", var.name)},)
}
resource "aws_security_group" "allow-mongodb" {
    name = "allow_mongodb"
    description = "Allow MongoDB"
    vpc_id = var.vpc_id

    ingress = [
    {
        description = "Allow MongoDB"
        from_port = var.mongo_port
        to_port = var.mongo_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]
    egress = [
    {
        description = "Allow all"
        from_port = 1
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        self = null
        prefix_list_ids = [] 
        security_groups = []
    }
]

    tags = merge(var.tags,{ "Name" = format("%s-allow-mongodb", var.name)},)
}
resource "aws_network_interface_sg_attachment" "mongodb-sg" {
    security_group_id = aws_security_group.allow-mongodb.id
    network_interface_id = aws_instance.mongodb-EC2.primary_network_interface_id
}
resource "aws_network_interface_sg_attachment" "slacko-sg" {
    security_group_id = aws_security_group.allow-slacko.id
    network_interface_id = aws_instance.slacko-EC2.primary_network_interface_id
}

resource "aws_route53_zone" "slack_zone" {
    name = "iaac0896.com.br"
    vpc {
        vpc_id = var.vpc_id
    }
    
    tags = merge(var.tags,{ "Name" = format("%s-iaac0506.com.br", var.name)},)
}
resource "aws_route53_record" "mongodb" {
    zone_id = aws_route53_zone.slack_zone.id
    name = "mongodb.iaac0896.com.br"
    type = "A"
    ttl = "300"
    records = [aws_instance.mongodb-EC2.private_ip]
}


