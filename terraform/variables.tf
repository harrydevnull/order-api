variable "project"{
    type = string
    description = "Project Name"
}

variable "environment" {
    type = string
    description = "Environment dev/staging/production"
}

variable "location" {
    type = string
    description = "Azure region to deploy to"
}
