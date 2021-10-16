variable "vpc_id" {
    type = string
    description = "ID da VPC"
}
variable "subnet_cidr" {
    type = string
    description = "Subnet Publica"
}
variable "ssh_port" {
    type = number
    default = 22
}
variable "http_port" {
    type = number
    default = 80
}
variable "mongo_port" {
    type = number
    default = 27017
}