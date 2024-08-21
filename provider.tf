provider "aws" {
  region     = local.region_default
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  allowed_account_ids = [local.service_account_id]
}

provider "aws" {
  alias      = "default"
  region     = local.region_default
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  allowed_account_ids = [local.service_account_id]
}

provider "aws" {
  alias      = "global"
  region     = local.region_global
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  allowed_account_ids = [local.service_account_id]
}

provider "aws" {
  alias      = "tokyo"
  region     = local.region_tokyo
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  allowed_account_ids = [local.service_account_id]
}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.rag.collection_endpoint
  aws_region  = local.region_default
  healthcheck = false
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

provider "opensearch" {
  alias       = "tokyo"
  url         = aws_opensearchserverless_collection.rag.collection_endpoint
  aws_region  = local.region_tokyo
  healthcheck = false
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}
