import requests
import json
import pandas as pd
import plotly.graph_objs as go

file_path = "../repository/env.json"
with open(file_path, "r") as json_file:
    env_data = json.load(json_file)
DATABASE_ID = env_data['DATABASE_ID']
url = f'https://api.notion.com/v1/databases/{DATABASE_ID}/query'
NOTION_KEY = env_data['NOTION_KEY']
NOTION_VERSION = "2022-02-22"
headers = {"Authorization": f"Bearer {NOTION_KEY}",
                       "Content-Type": "application/json",
                       "Notion-Version": NOTION_VERSION
}
body = {
    'sorts' : []
}
r = requests.post(url, data=json.dumps(body), headers=headers).json()
def convert_type(item):
    ret = {}
    ret['분류'] = item['properties']['분류']['select']['name']
    ret['금액'] = item['properties']['금액']['number']
    ret['결제일'] = item['properties']['결제일']['date']['start']
    ret['내용'] = item['properties']['내용']['title'][0]['text']['content']
    return ret

my_data = list(map(convert_type, r['results']))

df = pd.DataFrame(my_data) 
test = df.groupby(['분류']).sum()['금액']
data = go.Pie(labels = test.index, values=test.values)
layout = go.Layout(
    width=800,
    height=800,
    plot_bgcolor='#1f2c56',
    paper_bgcolor='#1f2c56',
    hovermode='closest',
    title={
        'text': '7월',
        'y': 0.93,
        'x': 0.5,
        'xanchor' : 'center',
        'yanchor' : 'top'
    },
    titlefont = {
        'color' : 'white',
        'size' : 20
    },
    legend={
        'orientation' : 'h',
        'bgcolor' : '#1f2c56',
        'xanchor' : 'center',
        #'x' : -0.5,
        #'y'  : -0.07
    },
    font=dict(
        family='sans-serif',
        size=12,
        color='white'
    )
)
figure = go.Figure(data=data, layout=layout)
figure.show()