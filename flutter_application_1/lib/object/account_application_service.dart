import '../repository/account_repository.dart';
import '../object/account.dart';

class AccountApplicationService {
  IaccountRepository accountRepository;
  Map databaseInfo;
  AccountApplicationService(this.accountRepository, this.databaseInfo);
  Future<List> load(String date) async {
    String databaseId = databaseInfo[date];
    return accountRepository.load(databaseId) as Future<List>;
  }

  String _getDatabaseId(String date) {
    // 2022-09-25 -> 202209
    if (date[4] != '-') {
      throw Exception('date is invalid');
    }
    String retDate = date[0] + date[1] + date[2] + date[3] + date[5] + date[6];
    return databaseInfo[retDate];
  }

  void save(Account data) {
    String databaseId = _getDatabaseId(data.date);
    accountRepository.save(databaseId, data);
  }

  void deleteItem(Account data) {
    String databaseId = _getDatabaseId(data.date);
    Future<String> blockId = accountRepository.query(databaseId, data);
    blockId.then((value) {
      accountRepository.deleteBlock(value);
    });
  }

  void editItem(Account before, Account after) {
    String databaseId = _getDatabaseId(before.date);
    Future<String> blockId = accountRepository.query(databaseId, before);
    blockId.then((value) {
      accountRepository.updateBlock(value, after);
    });
  }
}
