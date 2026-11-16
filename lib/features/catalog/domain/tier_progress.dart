import 'catalog_enums.dart';

class TierProgress {
  const TierProgress(this.tier, this.points);

  static const Map<Tier, int> floors = <Tier, int>{
    Tier.bronze: 0,
    Tier.silver: 500000,
    Tier.gold: 750000,
    Tier.platinum: 1000000,
  };

  final Tier tier;
  final int points;

  int get floor => floors[tier] ?? 0;

  Tier? get nextTier => tier.next;

  int get nextFloor {
    final next = nextTier;
    return next == null ? floor : (floors[next] ?? floor);
  }

  int get span => nextFloor - floor;

  double get fractionIntoTier {
    if (nextTier == null) {
      return 1;
    }
    if (span <= 0) {
      return 1;
    }
    return ((points - floor) / span).clamp(0.0, 1.0);
  }

  int get pointsToNext {
    if (nextTier == null) {
      return 0;
    }
    return (nextFloor - points).clamp(0, 1 << 31);
  }
}
