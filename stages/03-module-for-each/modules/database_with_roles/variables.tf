variable "database_name" {
  description = "Nazwa bazy danych, konczaca sie na _DB. Na jej podstawie powstaja tez nazwy rol (<NAZWA>_ADMIN, <NAZWA>_DEVELOPER)."
  type        = string

  # Provider rozroznia wielkosc liter w identyfikatorach, wiec pilnujemy jednej konwencji.
  validation {
    condition     = can(regex("^[A-Z][A-Z0-9_]*_DB$", var.database_name))
    error_message = "database_name musi zaczynac sie od wielkiej litery, zawierac tylko A-Z, 0-9 i _ oraz konczyc sie na _DB."
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
