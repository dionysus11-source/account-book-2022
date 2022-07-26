import 'dart:convert';
import 'package:http/http.dart' as http;
import '../object/account.dart';

abstract class IaccountRepository {
  void load();
  void save();
}

class AccountRepository implements IaccountRepository {
  String databaseId = '';
  String notionKey = '';
  String notionVersion = '';

  AccountRepository(this.databaseId, this.notionKey, this.notionVersion);

  @override
  void load() async {
    String url = 'https://api.notion.com/v1/databases/' + databaseId + '/query';
    final uri = Uri.parse(url);
    Map<String, String> headers = {
      "Authorization": "Bearer " + notionKey,
      "Content-Type": "application/json",
      "Notion-Version": notionVersion
    };
    http.Response response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      //print(json.decode(response.body)['results']);
      var test = json
          .decode(response.body)['results']
          .map((e) => Account.fromJson(e))
          .toList();
      print(test);
    } else {
      throw Exception('can not get data from notion');
    }
  }

  @override
  void save() {}
}
