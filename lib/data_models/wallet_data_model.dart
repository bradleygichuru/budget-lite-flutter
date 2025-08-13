class Wallet {
  final int? id;
  final String name;
  final double balance;
  final double savings;
  final int? accountId;

  Wallet({
    required this.accountId,
    this.id,
    required this.savings,
    required this.name,
    required this.balance,
  });

  Map<String, Object> toMap() {
    return {
      "id": ?id,
      "name": name,
      "balance": balance,
      'account_id': ?accountId,
      'savings': savings,
    };
  }

  @override
  String toString() {
    return 'Wallet{name:$name,balance:$balance:account_id:$accountId:savings:$savings}';
  }
}

class NotEnoughException implements Exception {
  String errMsg() => "Not enough balance";
}

class NotEnoughSavingsException implements Exception {
  String errMsg() => "Not enough savings";
}

class AccountWalletNotFoundException implements Exception {
  String errMsg() => "Wallet Not Found";
}
