variable "aws_region" {
  description = "Região AWS."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto."
  type        = string
  default     = "cloud-lab-02"
}

variable "ssh_cidr" {
  description = "CIDR permitido para SSH. Para laboratório pode ser 0.0.0.0/0."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Nome do Key Pair na AWS."
  type        = string
  default     = "cloud-lab-02-key"
}

variable "public_key_path" {
  description = "Caminho da chave pública."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Caminho da chave privada."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "instance_type" {
  description = "Tipo da instância."
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Porta publicada da aplicação."
  type        = number
  default     = 3000
}
