# Terraform for Amazon Bedrock RAG

流れ
1. tf apply
2. S3にデータをアップロード
3. ナレッジベースのデータソースからS3バケットを同期
4. ナレッジベース上でテスト
5. エージェントで「準備」を押してステータスをPREARDにする
6. エージェント上でテスト
7. エイリアス作成
8. 完成！
9. エイリアス削除
10. S3空にする
11. tf destory

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
