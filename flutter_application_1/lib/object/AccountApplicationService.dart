import '../repository/account_repository.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AccountApplicationService {
  IaccountRepository accountRepository;
  AccountApplicationService(this.accountRepository);
  Future<List> load() async {
    return accountRepository.load() as Future<List>;
  }
}
