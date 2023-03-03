variable "atlas_project_id" {
  description = "Atlas project ID (e.g. 5beae24579358e0ae95492af)"
  type        = string
}

variable "atlas_region" {
  description = "Atlas region (e.g. US_EAST_2)"
  type        = string
}

variable "aws_region" {
  description = "AWS region (e.g. us-east-2)"
  type        = string
}

variable "jumphost_ssh_key" {
  description = "SSH key for AWS jumphost (leave blank if not using jumphost or if connecting to jumphost via AWS console)"
  default     = ""
}
