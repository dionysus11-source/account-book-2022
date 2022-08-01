# %%
from re import I
import requests
import json
import pandas as pd
import plotly.graph_objs as go


file_path = "../repository/env.json"
with open(file_path, "r") as json_file:
    env_data = json.load(json_file)
NOTION_KEY = env_data['NOTION_KEY']
NOTION_VERSION = "2022-02-22"

def sendPost(database_id):
    url = f'https://api.notion.com/v1/databases/{database_id}/query'

    headers = {"Authorization": f"Bearer {NOTION_KEY}",
                       "Content-Type": "application/json",
                       "Notion-Version": NOTION_VERSION
    }
    body = {
     'sorts' : []
    }
    r = requests.post(url, data=json.dumps(body), headers=headers).json()
    return r

def getData(date,r):
    ret={}
    ret['날짜'] = date
    for result in r['results']:
        price = result['properties']['실천액']['number']
        category = result['properties']['항목']['title'][0]['text']['content']
        ret[category] = price
    return ret
# %%
with open('database_info.json','r') as f:
    database_info = json.load(f)
data=[]
for db in database_info:
    r = sendPost(db['database_id'])
    tt = getData(db['date'],r)
    data.append(tt)

# %%

# %%
import pandas as pd
df = pd.DataFrame(data)

# %%
df = df.fillna(0)

# %%
#df = df.astype(int)

# %%


# %%
# Bar 클래스 생성, name 인자로 범례 생성
data=[]
data.append(go.Bar(x=df['날짜'], y=df['의료'], name='의료'))
data.append(go.Bar(x=df['날짜'], y=df['의복미용'], name='의복미용'))
data.append(go.Bar(x=df['날짜'], y=df['여가활동'], name='여가활동'))
data.append(go.Bar(x=df['날짜'], y=df['교통'], name='교통'))
data.append(go.Bar(x=df['날짜'], y=df['생활용품'], name='생활용품'))
data.append(go.Bar(x=df['날짜'], y=df['기타'], name='기타'))
data.append(go.Bar(x=df['날짜'], y=df['육아'], name='육아'))
data.append(go.Bar(x=df['날짜'], y=df['용돈'], name='용돈'))
data.append(go.Bar(x=df['날짜'], y=df['식비'], name='식비'))
data.append(go.Bar(x=df['날짜'], y=df['꿈지출'], name='꿈지출'))
layout = go.Layout(title='가계부', barmode='stack') # Title 설정 & Stack으로 그리기
 
# 생성된 Bar 클래스를 리스트로 짜들어 data 인자로 설동
fig = go.Figure(data=data, layout=layout)
fig.show()

# %%


# %%



