enum UserType {
  developer,
  admin,
  regular;

  static UserType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'developer':
        return UserType.developer;
      case 'admin':
        return UserType.admin;
      case 'regular':
        return UserType.regular;
      default:
        throw Exception('Unknown UserType: $value');
    }
  }

  String toShortString() => name;
}
