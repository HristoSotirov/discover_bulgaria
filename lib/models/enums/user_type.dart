enum UserType {
  admin,
  user;

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserType.admin;
      case 'regular':
        return UserType.user;
      default:
        throw Exception('Unknown UserType: $value');
    }
  }

  String toShortString() => name;
}
