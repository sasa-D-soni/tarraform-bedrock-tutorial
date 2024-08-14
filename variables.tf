#
# Region
#
locals {
  workspace_regions = {
    default  = "us-east-1"
    virginia = "us-east-1"
    tokyo    = "ap-northeast-1"
  }

  # デフォルトのリージョン
  region_default = local.workspace_regions["default"]

  # グローバルリージョン
  region_global = local.workspace_regions["virginia"]

  # 東京リージョン
  region_tokyo = local.workspace_regions["tokyo"]
}

#
# Account
#
locals {
  # 必ずダブルコーテーションで囲むこと
  service_account_id = "000000000"

  # 展開するサービス名
  service_name = "summer-example"
}

#
# Key
#
variable "aws_access_key" {
}

variable "aws_secret_key" {
}
