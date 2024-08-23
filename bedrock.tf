locals {
  opensearch_collection_name = "${local.service_name}-br-knowledge-base"
  # agent_model                = "anthropic.claude-3-5-sonnet-20240620-v1:0" # claude-3-5-sonnetは provider5.60.0だと使えなかった
  agent_model         = "anthropic.claude-3-sonnet-20240229-v1:0"
  embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
}

#
# aws_bedrockagent_agent
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_agent
# https://docs.aws.amazon.com/ja_jp/bedrock/latest/userguide/model-ids.html
resource "aws_bedrockagent_agent" "rag" {
  agent_name                  = "${local.service_name}-rag-agent"
  agent_resource_role_arn     = aws_iam_role.rag-agents.arn
  idle_session_ttl_in_seconds = 500
  foundation_model            = local.agent_model
  prepare_agent               = false
  instruction                 = <<TEXT
保存されているファイルは学生が研究活動のため参考にしている論文です。
質問者は大学の情報学部で卒業研究をおこなっている学生です。
学生が参考にする論文に対して、なるべくわかりやすい日本語で解答をしてください。
TEXT

  lifecycle {
    ignore_changes = [instruction]
  }
}

#
# aws_bedrockagent_agent_alias
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_agent_alias
# [NOTE] エイリアスは手動でも作成されるケースがあるため、terraformで作らない
# resource "aws_bedrockagent_agent_alias" "rag" {
#   agent_alias_name = "${local.service_name}-rag-agent-alias"
#   agent_id         = aws_bedrockagent_agent.rag.agent_id
#   description      = "${local.service_name} Alias"
# }

#
# aws_bedrockagent_agent_knowledge_base_association
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_agent_knowledge_base_association
resource "aws_bedrockagent_agent_knowledge_base_association" "rag" {
  agent_id             = aws_bedrockagent_agent.rag.id
  description          = "Knowledge base for RAG"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.rag.id
  knowledge_base_state = "ENABLED"
}

#
# aws_bedrockagent_data_source
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source
resource "aws_bedrockagent_data_source" "rag" {
  knowledge_base_id    = aws_bedrockagent_knowledge_base.rag.id
  name                 = "${local.service_name}-rag-data-source"
  data_deletion_policy = "RETAIN"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.rag.arn
    }
  }
}


#
# aws_bedrockagent_knowledge_base
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base
resource "aws_bedrockagent_knowledge_base" "rag" {
  name     = "${local.service_name}-rag"
  role_arn = aws_iam_role.rag-knowledge-base.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = local.embedding_model_arn
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.rag.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
  depends_on = [time_sleep.opensearch_index_delay]
}

#
# aws_opensearchserverless_collection
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection
data "aws_caller_identity" "current" {}

# ネットワークポリシー
resource "aws_opensearchserverless_security_policy" "rag-network" {
  name = "${local.service_name}-br-knowledge-base"
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "dashboard",
          Resource = [
            "collection/${local.opensearch_collection_name}"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.opensearch_collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])

  # [NOTE] json直書きだとバグでエラーになる。
  # ╷
  # │ Error: Provider produced inconsistent result after apply
  # │ 
  # │ When applying changes to aws_opensearchserverless_security_policy.rag, provider "provider[\"registry.terraform.io/hashicorp/aws\"]" produced an unexpected new value: .policy: was cty.StringVal("[\n  {\n
  # │ \"Rules\": [\n      {\n        \"Resource\": [\n          \"collection/summer-example-br-knowledge-base\"\n        ],\n        \"ResourceType\": \"dashboard\"\n      },\n      {\n        \"Resource\": [\n
  # │ \"collection/summer-example-br-knowledge-base\"\n        ],\n        \"ResourceType\": \"collection\"\n      }\n    ],\n    \"AllowFromPublic\": true\n  }\n]\n"), but now
  # │ cty.StringVal("[{\"AllowFromPublic\":true,\"Rules\":[{\"Resource\":[\"collection/summer-example-br-knowledge-base\"],\"ResourceType\":\"dashboard\"},{\"Resource\":[\"collection/summer-example-br-knowledge-base\"],\"ResourceType\":\"collection\"}]}]").
  # │ 
  # │ This is a bug in the provider, which should be reported in the provider's own issue tracker.
  #   policy = <<JSON
  # [
  #   {
  #     "Rules": [
  #       {
  #         "Resource": [
  #           "collection/${local.opensearch_collection_name}"
  #         ],
  #         "ResourceType": "dashboard"
  #       },
  #       {
  #         "Resource": [
  #           "collection/${local.opensearch_collection_name}"
  #         ],
  #         "ResourceType": "collection"
  #       }
  #     ],
  #     "AllowFromPublic": true
  #   }
  # ]
  # JSON
}

# 暗号化ポリシー
resource "aws_opensearchserverless_security_policy" "rag-encryption" {
  name = "${local.service_name}-br-knowledge-base"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${local.opensearch_collection_name}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# データアクセスポリシー
resource "aws_opensearchserverless_access_policy" "rag" {
  name        = "${local.service_name}-br-knowledge-base"
  type        = "data"
  description = "read and write permissions"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.opensearch_collection_name}"
          ],
          Permission = [
            "aoss:DescribeCollectionItems",
            "aoss:CreateCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        },
        {
          ResourceType = "index",
          Resource = [
            "index/${local.opensearch_collection_name}/*"
          ],
          Permission = [
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument",
            "aoss:CreateIndex",
            "aoss:DeleteIndex"
          ]
        }
      ],
      Principal = [
        "${aws_iam_role.rag-knowledge-base.arn}",
        "${data.aws_caller_identity.current.arn}"
      ]
    }
  ])
}

# Opensearch コレクション
resource "aws_opensearchserverless_collection" "rag" {
  name = local.opensearch_collection_name
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.rag-network,
    aws_opensearchserverless_security_policy.rag-encryption
  ]
}

# collection作成直後にインデックスを作成しようとすると403エラーが起こるため遅延を入れる
resource "time_sleep" "opensearchserverless_collection_delay" {
  create_duration = "30s"
  depends_on      = [aws_opensearchserverless_collection.rag]
}

# インデックス
# https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/index
resource "opensearch_index" "rag" {
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings = jsonencode({
    properties = {
      bedrock-knowledge-base-default-vector = {
        type      = "knn_vector"
        dimension = 1024 # amazon.titan-embed-text-v2で利用できるベクトル次元
        method = {
          name   = "hnsw"
          engine = "faiss"
          parameters = {
            m               = 16
            ef_construction = 512
          }
          space_type = "l2"
        }
      },
      AMAZON_BEDROCK_METADATA = {
        type  = "text"
        index = false
      }
      AMAZON_BEDROCK_TEXT_CHUNK = {
        type  = "text"
        index = true
      }
    }
  })
  force_destroy = true

  depends_on = [time_sleep.opensearchserverless_collection_delay]
  lifecycle {
    ignore_changes = [
      mappings
    ]
  }
}

resource "time_sleep" "opensearch_index_delay" {
  create_duration = "30s"
  depends_on      = [opensearch_index.rag]
}


#
# aws_s3_bucket
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "rag" {
  bucket = "hands-on-${local.service_name}-rag-data-source"
}
