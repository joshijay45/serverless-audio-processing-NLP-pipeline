variable "aws_region" {
  description = "AWS Region"
  type = string
  default = "us-east-1"
}

variable "project_name" {
    description = "The Automated audio video content summarizer"
    type = string
    default = "audio-video-content-summarizer"
}

variable "targeted_language" {
    description = "Targeted language for AWS translate"
    type = string
    default = "es" 
}

