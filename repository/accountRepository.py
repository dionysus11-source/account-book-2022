from sqlite3 import DatabaseError
from . import IaccountRepository
import sys
import os
import json
import requests
from . import CategoryID
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))
from object import account


class accountRepository(IaccountRepository.IaccountRepository):
    def __init__(self):
        path = os.path.dirname(os.path.realpath(__file__)) 
        file_path = f"{path}\\env.json"
        with open(file_path, "r") as json_file:
            env_data = json.load(json_file)
        self.__DATABASE_ID = env_data['DATABASE_ID']
        self.__NOTION_KEY = env_data['NOTION_KEY']
        self.__NOTION_VERSION = "2022-02-22"
        pass

    def __make_property(self,input):
        if isinstance(input, account.Account) is False:
            print("data type error")
            return
        output = {
            'parent': {
                'database_id': self.__DATABASE_ID,
            },
            'properties': {
                '분류': CategoryID.categoryID[input.category],
                '금액': {'number': input.ammount},
                '결제일': {'id': 'nx%60~',
                        'type': 'date',
                        'date': {'start': input.date, 'end': None, 'time_zone': None}},
                '내용': {
                    'title': [
                        {
                            'text': {'content': input.content}
                        },
                    ]
                }
            }
        }
        return output

    def save(self, data):
        if isinstance(data, account.Account) is False:
            print("data type error")
            return
        headers = {"Authorization": f"Bearer {self.__NOTION_KEY}",
                   "Content-Type": "application/json",
                   "Notion-Version": self.__NOTION_VERSION
        }
        body = {
            'sorts': []
        }
        url = f'https://api.notion.com/v1/pages'
        datas = self.__make_property(data)
        r = requests.post(url, data=json.dumps(datas), headers=headers).json()
        
    def __makeAccount(self, resp):
        ret = {}
        ret['분류'] = resp['properties']['분류']['select']['name']
        ret['금액'] = resp['properties']['금액']['number']
        ret['결제일'] = resp['properties']['결제일']['date']['start']
        ret['내용'] = resp['properties']['내용']['title'][0]['text']['content']
        return account.Account(ret)

    def load(self):
        url = f'https://api.notion.com/v1/databases/{self.__DATABASE_ID}/query'
        headers = {"Authorization": f"Bearer {self.__NOTION_KEY}",
                   "Content-Type": "application/json",
                   "Notion-Version": self.__NOTION_VERSION
        }
        r = requests.post(url, headers=headers).json()
        ret = list(map(self.__makeAccount, r['results']))
        return ret
