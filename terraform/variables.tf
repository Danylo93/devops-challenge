# Define variáveis reutilizáveis
variable "resource_group_name" {
  default = "rg-devops"
}

variable "location" {
  default = "eastus"
}

variable "acr_name" {
  default = "acrdevopschallenge"
}

variable "aks_name" {
  default = "aksdevopschallenge"
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
