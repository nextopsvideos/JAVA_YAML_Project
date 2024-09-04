# Variables
variable "environments" {
  description = "List of environments"
  type        = list(string)
  default     = ["dev", "staging"]
}

variable "location" {
  description = "The location for all resources"
  default     = "West US"
}
