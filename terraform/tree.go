package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	// Especifica la ruta de la carpeta que deseas recorrer
	root := "./"

	// Lista de carpetas y archivos que deseas omitir
	excludeDirs := []string{"node_modules", ".git", ".terragrunt-cache", ".terraform"}
	excludeFiles := []string{"terragrunt.hcl", "*.tfstate*", "*.backup", ".terraform.lock.hcl"}

	// Llama a la función para recorrer la carpeta
	err := listFiles(root, "", excludeDirs, excludeFiles)
	if err != nil {
		fmt.Println("Error:", err)
	}
}

func listFiles(path string, prefix string, excludeDirs []string, excludeFiles []string) error {
	// Lee el contenido de la carpeta
	files, err := os.ReadDir(path)
	if err != nil {
		return err
	}

	for i, file := range files {
		// Determina si es el último archivo en la lista
		isLast := i == len(files)-1

		// Construye el prefijo para la jerarquía
		newPrefix := prefix
		if isLast {
			fmt.Printf("%s└── %s", prefix, file.Name())
			newPrefix += "    "
		} else {
			fmt.Printf("%s├── %s", prefix, file.Name())
			newPrefix += "│   "
		}

		// Verifica si el archivo o carpeta debe ser omitido
		if shouldExclude(file, excludeDirs, excludeFiles) {
			fmt.Println(" (omitido)")
			continue
		}

		// Si es un archivo, verifica si es .tf o .hcl y no es un archivo de Terragrunt
		if !file.IsDir() {
			ext := filepath.Ext(file.Name())
			if (ext == ".tf" || ext == ".hcl") && !isTerragruntFile(file.Name()) {
				content, err := os.ReadFile(filepath.Join(path, file.Name()))
				if err != nil {
					fmt.Println(" (Error al leer el archivo)")
				} else {
					// Limpia el contenido del archivo
					cleanedContent := strings.ReplaceAll(string(content), "\n", " ")
					cleanedContent = strings.Join(strings.Fields(cleanedContent), " ")
					fmt.Printf(": %s\n", cleanedContent)
				}
			} else {
				fmt.Println(" (omitido)")
			}
		} else {
			fmt.Println()
		}

		// Si es una carpeta, llama recursivamente a la función
		if file.IsDir() {
			err := listFiles(filepath.Join(path, file.Name()), newPrefix, excludeDirs, excludeFiles)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

// Función para determinar si un archivo es de Terragrunt y debe omitirse
func isTerragruntFile(filename string) bool {
	// Lista de archivos de Terragrunt que deben omitirse
	terragruntFiles := []string{"terragrunt.hcl", "terraform.tfvars", "terraform.tfstate", "terraform.tfstate.backup"}
	for _, tfFile := range terragruntFiles {
		if filename == tfFile {
			return true
		}
	}
	return false
}

// Función para determinar si un archivo o carpeta debe ser omitido
func shouldExclude(file os.DirEntry, excludeDirs []string, excludeFiles []string) bool {
	// Verifica si es una carpeta y si debe ser omitida
	if file.IsDir() {
		for _, dir := range excludeDirs {
			if file.Name() == dir {
				return true
			}
		}
		return false
	}

	// Verifica si es un archivo y si debe ser omitido
	for _, pattern := range excludeFiles {
		if strings.HasPrefix(pattern, "*") {
			// Si el patrón es una extensión (e.g., *.tfstate*)
			ext := strings.TrimPrefix(pattern, "*")
			if strings.HasSuffix(file.Name(), ext) {
				return true
			}
		} else if file.Name() == pattern {
			// Si el patrón es un nombre completo de archivo
			return true
		}
	}
	return false
}
