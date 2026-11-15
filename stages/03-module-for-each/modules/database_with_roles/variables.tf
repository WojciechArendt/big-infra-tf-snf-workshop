variable "name_prefix" {
  description = "Wspolny prefiks nazw obiektow modulu: baza <PREFIKS>_DB, role <PREFIKS>_ADMIN i <PREFIKS>_DEVELOPER."
  type        = string

  # Provider rozroznia wielkosc liter w identyfikatorach, wiec pilnujemy jednej konwencji.
  validation {
    condition     = can(regex("^[A-Z][A-Z0-9_]*$", var.name_prefix))
    error_message = "name_prefix musi zaczynac sie od wielkiej litery i zawierac tylko A-Z, 0-9 i _."
  }
}

variable "warehouse_name" {
  description = "Nazwa istniejacego warehouse'u, na ktorym rola developera dostanie USAGE (warehouse tworzony poza modulem)."
  type        = string
}

variable "comment" {
  description = "Komentarz dodawany do tworzonych obiektow."
  type        = string
  default     = "Managed by Terraform"
}
