import 'dart:convert';
import 'package:http/http.dart' as http;
import '../object/account.dart';

abstract class IaccountRepository {
  void load(String databaseId);
  void save(String databaseId, Account data);
  Future<String> query(String databaseId, Account data);
  void deleteBlock(String blockId);
  void updateBlock(String blockId, Account data);
}

class AccountRepository implements IaccountRepository {
  String notionKey = '';
  String notionVersion = '';

  AccountRepository(this.notionKey, this.notionVersion);

  @override
  Future<List> load(String databaseId) async {
    String url = 'https://api.notion.com/v1/databases/' + databaseId + '/query';
    final uri = Uri.parse(url);
    Map<String, String> headers = {
      "Authorization": "Bearer " + notionKey,
      "Content-Type": "application/json",
      "Notion-Version": notionVersion
    };
    http.Response response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var ret = json
          .decode(response.body)['results']
          .map((e) => Account.fromJson(e))
          .toList();
      return ret;
    } else {
      throw Exception('can not get data from notion');
    }
  }

  @override
  void save(String databaseId, Account data) async {
    String url = 'https://api.notion.com/v1/pages';
    final uri = Uri.parse(url);
    Map<String, String> headers = {
      "Authorization": "Bearer " + notionKey,
      "Content-Type": "application/json",
      "Notion-Version": notionVersion
    };
    final body = jsonEncode({
      'parent': {'database_id': databaseId},
      'properties': {
        "내용": {
          "title": [
            {
              "text": {"content": data.content}
            }
          ]
        },
        "분류": {
          'select': {'name': data.category}
        },
        '금액': {'number': data.ammount},
        '결제일': {
          'date': {'start': data.date}
        }
      }
    });
    http.Response response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
    } else {
      throw Exception('can not get data from notion');
    }
  }

  @override
  Future<String> query(String databaseId, Account data) async {
    String url = 'https://api.notion.com/v1/databases/' + databaseId + '/query';
    final uri = Uri.parse(url);
    Map<String, String> headers = {
      "Authorization": "Bearer " + notionKey,
      "Content-Type": "application/json",
      "Notion-Version": notionVersion
    };
    final body = jsonEncode({
      "filter": {
        "and": [
          {
            "property": "내용",
            "rich_text": {"equals": data.content}
          },
          {
            "property": "금액",
            "number": {"equals": data.ammount}
          },
          {
            "property": "결제일",
            "date": {"equals": data.date}
          }
        ]
      }
    });
    http.Response response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      var ret = json.decode(response.body)['results'][0]['id'];
      return ret;
    } else {
      throw Exception('can not get data from notion');
    }
  }

  @override
  void deleteBlock(String blockId) async {
    String url = 'https://api.notion.com/v1/blocks/' + blockId;
    final uri = Uri.parse(url);
    Map<String, String> headers = {
      "Authorization": "Bearer " + notionKey,
      "Content-Type": "application/json",
      "Notion-Version": notionVersion
    };
    http.Response response = await http.delete(uri, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('can not get data from notion');
    }
  }

  @override
  void updateBlock(String blockId, Account data) async {
    String url = 'https://api.notion.com/v1/blocks/' + blockId;
    url = 'https://api.notion.com/v1/pages/' + blockId;
    final uri = Uri.parse(url);
    Map<String, String> headers = {
      "Authorization": "Bearer " + notionKey,
      "Content-Type": "application/json",
      "Notion-Version": notionVersion
    };
    final body = jsonEncode({
      'properties': {
        "내용": {
          "title": [
            {
              "text": {"content": data.content}
            }
          ]
        },
        "분류": {
          'select': {'name': data.category}
        },
        '금액': {'number': data.ammount},
        '결제일': {
          'date': {'start': data.date}
        }
      }
    });
    http.Response response =
        await http.patch(uri, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('can not get data from notion');
    }
  }
}
