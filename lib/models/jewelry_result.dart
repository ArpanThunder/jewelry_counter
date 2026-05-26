class JewelryResult {
  final int goldBalls;
  final int diamonds;
  final int rubies;
  final int emeralds;
  final int sapphires;
  final int pearls;
  final int otherStones;
  final String otherStonesType;
  final String jewelryType;
  final String metal;
  final String confidence;
  final String description;
  final String notes;
  final DateTime scannedAt;

  JewelryResult({
    required this.goldBalls,
    required this.diamonds,
    required this.rubies,
    required this.emeralds,
    required this.sapphires,
    required this.pearls,
    required this.otherStones,
    required this.otherStonesType,
    required this.jewelryType,
    required this.metal,
    required this.confidence,
    required this.description,
    required this.notes,
    required this.scannedAt,
  });

  int get totalGoldBalls => goldBalls;
  int get totalDiamonds => diamonds;
  int get totalColoredStones => rubies + emeralds + sapphires + pearls + otherStones;
  int get totalElements =>
      goldBalls + diamonds + rubies + emeralds + sapphires + pearls + otherStones;

  factory JewelryResult.fromMap(Map<String, dynamic> map) {
    return JewelryResult(
      goldBalls:      _parseInt(map['goldBalls']),
      diamonds:       _parseInt(map['diamonds']),
      rubies:         _parseInt(map['rubies']),
      emeralds:       _parseInt(map['emeralds']),
      sapphires:      _parseInt(map['sapphires']),
      pearls:         _parseInt(map['pearls']),
      otherStones:    _parseInt(map['otherStones']),
      otherStonesType: map['otherStonesType']?.toString() ?? 'none',
      jewelryType:    map['jewelryType']?.toString() ?? 'unknown',
      metal:          map['metal']?.toString() ?? 'unknown',
      confidence:     map['confidence']?.toString() ?? 'low',
      description:    map['description']?.toString() ?? '',
      notes:          map['notes']?.toString() ?? '',
      scannedAt:      DateTime.now(),
    );
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toMap() => {
    'goldBalls': goldBalls,
    'diamonds': diamonds,
    'rubies': rubies,
    'emeralds': emeralds,
    'sapphires': sapphires,
    'pearls': pearls,
    'otherStones': otherStones,
    'otherStonesType': otherStonesType,
    'jewelryType': jewelryType,
    'metal': metal,
    'confidence': confidence,
    'description': description,
    'notes': notes,
    'scannedAt': scannedAt.toIso8601String(),
  };
}
