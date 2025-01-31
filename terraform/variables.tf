variable "country" {
  description = "El país donde se despliega el recurso"
  type        = string
}

variable "environment" {
  description = "El ambiente de despliegue (dev, staging, prod)"
  type        = string
}

variable "product" {
  description = "El nombre del producto o servicio"
  type        = string
  default     = "contacts"
}

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}