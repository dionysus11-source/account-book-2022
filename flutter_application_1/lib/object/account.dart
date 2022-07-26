class Account {
  String category;
  int ammount;
  String date;
  String content;
  Account(
      {required this.category,
      required this.ammount,
      required this.date,
      required this.content});

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'ammount': ammount,
      'date': date,
      'content': content
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        category: json['properties']['분류']['select']['name'],
        ammount: json['properties']['금액']['number'],
        date: json['properties']['결제일']['date']['start'],
        content: json['properties']['내용']['title'][0]['text']['content']);
  }
}
