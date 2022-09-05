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

  void save(String date, Account data) {
    String databaseId = databaseInfo[date];
    accountRepository.save(databaseId, data);
  }

  void deleteItem(String date, Account data) {
    String databaseId = databaseInfo[date];
    Future<String> blockId = accountRepository.query(databaseId, data);
    blockId.then((value) {
      accountRepository.deleteBlock(value);
    });
  }
}
