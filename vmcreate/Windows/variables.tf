variable "resource_prefix" {
    default = "windowsvm"
}
variable "vm_name" {
    type = string
}
variable "vm_size" {
    default = "Standard_B1s"
}
variable "location" {
    type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
  sensitive = true
}