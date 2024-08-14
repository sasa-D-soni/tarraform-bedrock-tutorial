terraform {
  required_version = ">= 1.8.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3.0"
    }
  }
}
