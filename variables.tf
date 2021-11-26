#############################
## Application - Variables ##
#############################

# company prefix 
variable "prefix" {
  type        = string
  description = "This variable defines the company name prefix used to build resources"
}

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
}


#############################################
# Azure Database for PostgreSQL - Variables #
#############################################

variable "postgresql-admin-login" {
  type        = string
  description = "Login to authenticate to PostgreSQL Server"
}
variable "postgresql-version" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "11"
}

variable "postgresql-sku-name" {
  type        = string
  description = "PostgreSQL SKU Name"
  default     = "B_Gen5_1"
}

variable "postgresql-storage" {
  type        = string
  description = "PostgreSQL Storage in MB, from 5120 MB to 4194304 MB"
  default     = "5120"
}