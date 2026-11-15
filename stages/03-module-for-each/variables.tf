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

variable "name_prefixes" {
  description = "Prefiksy nazw. Dla kazdego modul utworzy baze <PREFIKS>_DB oraz role <PREFIKS>_ADMIN i <PREFIKS>_DEVELOPER."
  type        = list(string)
  default = [
    "SALES",
    "MARKETING",
    "FINANCE",
    "HR",
    "LOGISTICS",
    "PRODUCTION",
    "SUPPORT",
    "ANALYTICS",
    "LEGAL",
    "IT",
  ]
}
