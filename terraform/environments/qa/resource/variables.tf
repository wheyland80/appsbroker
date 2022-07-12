variable "project_id" {
  description = "The ID of the project in which resources will be provisioned."
  default     = ""
}

variable "region" {
  description = "The project region"
  default     = ""
}

variable "env" {
  description = "Target Environment"
  default = ""
}

variable "layer" {
  description = "Target Layer"
  default = ""
}