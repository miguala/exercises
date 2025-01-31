# Terraform Project: Gestión de Infraestructura como Código

Este repositorio contiene la configuración de Terraform para desplegar recursos en AWS. La estructura está diseñada para ser modular y flexible, permitiendo la gestión de múltiples entornos (dev, staging, prod) y países (arg, bra, etc.) mediante archivos de variables (.tfvars).

## Estructura del Proyecto

```
.
├── main.tf                  # Configuración principal de recursos
├── variables.tf             # Variables globales con valores por defecto
├── dev-arg.tfvars           # Valores específicos para dev en Argentina
├── prod-bra.tfvars          # Valores específicos para prod en Brasil
├── modules/                 # Módulos reutilizables
└── providers.tf             # Configuración de proveedores
```

## Uso de Archivos .tfvars

Los archivos `.tfvars` permiten definir valores específicos para las variables declaradas en `variables.tf`. Esto facilita la gestión de diferentes entornos y configuraciones sin modificar el código base.

## Cómo Usar los Archivos .tfvars

Para aplicar la configuración de Terraform con un archivo `.tfvars` específico, utiliza el siguiente comando:

```bash
terraform apply -var-file="<nombre-del-archivo>.tfvars"
```
