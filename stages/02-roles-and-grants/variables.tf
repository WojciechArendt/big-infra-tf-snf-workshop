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
