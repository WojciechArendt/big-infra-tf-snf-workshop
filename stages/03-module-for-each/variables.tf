variable "warehouse_size" {
  description = "Rozmiar warehouse'u warsztatowego."
  type        = string
  default     = "XSMALL"
}

variable "warehouse_auto_suspend_seconds" {
  description = "Po ilu sekundach bezczynnosci warehouse sie wylacza."
  type        = number
  default     = 60
}

variable "database_names" {
  description = "Nazwy baz danych, dla ktorych modul utworzy komplet zasobow (baza + role + granty)."
  type        = list(string)
  default = [
    "SALES_DB",
    "MARKETING_DB",
    "FINANCE_DB",
    "HR_DB",
    "LOGISTICS_DB",
    "PRODUCTION_DB",
    "SUPPORT_DB",
    "ANALYTICS_DB",
    "LEGAL_DB",
    "IT_DB",
  ]
}
