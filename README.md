# Terraform for Amazon Bedrock RAG

流れ
1. `$ mv terraform.tfvars.sample terraform.tfvars`
2. `$ vi terraform.tfvars` AWSのキー情報を設定
3. `$ vi variables.tf`  
   - `service_account_id` にAWSのアカウントidを設定
   - `service_name` に適当な名前を設定
4. `$ terraform init`
5. `$ terraform apply`
6. S3にデータをアップロード
7. ナレッジベースのデータソースからS3バケットを同期
8. ナレッジベース上でテスト
9. エージェントで「準備」を押してステータスをPREPAREDにする
10. エージェント上でテスト
11. エイリアス作成
12. 完成！
13. エイリアス削除
14. S3空にする
15. `$ terraform destory`

## エージェント向けの指示(instruction) 例文

```
保存されているファイルは学生が研究活動のため参考にしている論文です。
質問者は大学の情報学部で卒業研究をおこなっている学生です。
学生が参考にする論文に対して、なるべくわかりやすい日本語で解答をしてください。
```

## プロンプト例文

```
Vtuberにおけるソーシャルネットワークに関する分析の論文について、概要を教えてください
```


## Python boto3でagentを呼び出す

credentialsの設定を忘れずに

```
❯ python3 scripts/invoke_agent.py 
```

## ローカルのstreamlitでブラウザ上で動かせるようにする

```
❯ pip install streamlit

# asdfを使っている場合、reshimを実行する
❯ which python3
❯ asdf reshim 

❯ streamlit run scripts/invoke_agent_on_browser.py --server.port 8080
```
