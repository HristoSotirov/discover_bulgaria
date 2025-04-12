enum RankType {
  beginner,
  intermediate,
  advanced,
  expert;

  static RankType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return RankType.beginner;
      case 'intermediate':
        return RankType.intermediate;
      case 'advanced':
        return RankType.advanced;
      case 'expert':
        return RankType.expert;
      default:
        throw Exception('Unknown RankType: $value');
    }
  }

  String toShortString() => name;
}
