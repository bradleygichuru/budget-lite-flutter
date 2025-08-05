enum Country {
  other('other'),
  kenya('kenya');

  final String name;
  const Country(this.name);
}

class Account {
  final int? id;
  final String email;
  final String? country;
  final String? budgetResetDate;
  final String? authId;
  final String createdAt;
  final String tier;
  final int? resetPending;
  Account({
    required this.email,
    required this.createdAt,
    this.authId,
    this.id,
    this.resetPending,
    this.country,
    this.budgetResetDate,
    required this.tier,
  });
  Map<String, Object> toMap() {
    return {
      'auth_id': ?authId,
      'id': ?id,
      'email': email,
      'country': ?country,
      'budget_reset_date': ?budgetResetDate,
      'account_tier': tier,
      'created_at': createdAt,
      'resetPending': ?resetPending,
    };
  }

  @override
  String toString() {
    return 'Account{id:$id,email:$email,auth_id:$authId,country:$country,budget_reset_date:$budgetResetDate,createdAt:$createdAt,tier:$tier,resetPending:$resetPending}';
  }
}

class AccountIdNullException implements Exception {
  @override
  String toString() => "Account id null";
}

class NoAccountFound implements Exception {
  @override
  String toString() => "Account id null";
}

class ErrorLogginIn implements Exception {
  @override
  String toString() => "Login error";
}

class InvalidEmailOrPassword implements Exception {
  @override
  String toString() => 'INVALID_EMAIL_OR_PASSWORD';
}

class ErrorRegistering implements Exception {
  @override
  String toString() => "Registering error";
}

class AccountAlreadyExists implements Exception {
  @override
  String toString() => "Account Already exists";
}
