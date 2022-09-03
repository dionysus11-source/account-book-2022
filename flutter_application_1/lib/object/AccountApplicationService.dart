import '../repository/account_repository.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AccountApplicationService {
  IaccountRepository accountRepository;
  Map databaseInfo;
  AccountApplicationService(this.accountRepository, this.databaseInfo);
  Future<List> load(String date) async {
    String databaseId = databaseInfo[date];
    return accountRepository.load(databaseId) as Future<List>;
  }
}
