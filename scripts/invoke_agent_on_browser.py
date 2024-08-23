import uuid
import boto3
import streamlit as st

# Agentの定義
agent_id='XXX'
agent_alias_id='XXX'
session_id = str(uuid.uuid1())

# Clientの定義
client = boto3.client('bedrock-agent-runtime', region_name='us-east-1')

st.title("Bedrock AgentからのKnowledge base呼出し")
input_text = st.text_input("このテキストをAgentに送信します")
send_button = st.button("送信")


if send_button:
    result_area = st.empty()
    text = ''

    # Agentの実行
    response = client.invoke_agent(
        inputText=input_text,
        agentId=agent_id,
        agentAliasId=agent_alias_id,
        sessionId=session_id,
        enableTrace=False
    )

    # Agent実行結果の取得
    event_stream = response['completion']
    for event in event_stream:
        if 'chunk' in event:
            text += event['chunk']['bytes'].decode("utf-8")
            result_area.write(text)
