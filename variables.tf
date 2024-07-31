variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Local onde o grupo de recursos sera criado"
}

variable "resource_group_name" {
  type        = string
  default     = "student-rg"
  description = "Nome do grupo de recursos"
}

variable "username" {
  type        = string
  description = "O usuario que sera usado para nos conectarmos nas VMs"
  default     = "azureuser"
}

variable "vm_admin_password" {
  type        = string
  description = "Senha do usuário da VM"
}
