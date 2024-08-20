import boto3
import uuid

input_text="Vtuberにおけるソーシャルネットワークに関する分析の論文について、概要を教えてください"

# Agentの定義
agent_id='RWCQHBNOAA'
agent_alias_id='CAOT61SJSH'
session_id = str(uuid.uuid1())

client = boto3.client('bedrock-agent-runtime', region_name='us-east-1')

response = client.invoke_agent(
  agentId=agent_id,
  agentAliasId=agent_alias_id,
  sessionId=session_id,
  inputText=input_text,
  enableTrace=False
)

print(f"response: {response}")
event_stream = response['completion']
for event in event_stream:
    if 'chunk' in event:
        data = event['chunk']['bytes'].decode("utf-8")
        print(data)

