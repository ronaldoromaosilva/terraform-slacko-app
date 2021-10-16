module "slackoapp" {
  source      = "./modules/slacko"
  vpc_id      = "vpc-13d32ipcae201a2ed"
  subnet_cidr = "10.0.112.0/24"
  name        = "Slacko" 
}

output "slackoip" {
  value = module.slackoapp.slacko  
}
