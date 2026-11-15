import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Tier {
  @JsonValue('bronze')
  bronze,
  @JsonValue('silver')
  silver,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum;

  static Tier fromName(String name) {
    return switch (name.toLowerCase()) {
      'bronze' => Tier.bronze,
      'silver' => Tier.silver,
      'gold' => Tier.gold,
      'platinum' => Tier.platinum,
      _ => Tier.bronze,
    };
  }

  int get rank => switch (this) {
    Tier.bronze => 0,
    Tier.silver => 1,
    Tier.gold => 2,
    Tier.platinum => 3,
  };

  Tier? get next => switch (this) {
    Tier.bronze => Tier.silver,
    Tier.silver => Tier.gold,
    Tier.gold => Tier.platinum,
    Tier.platinum => null,
  };
}

@JsonEnum()
enum ChallengeKind {
  @JsonValue('donut')
  donut,
  @JsonValue('coffee')
  coffee;

  static ChallengeKind fromName(String name) {
    return switch (name.toLowerCase()) {
      'donut' => ChallengeKind.donut,
      'coffee' => ChallengeKind.coffee,
      _ => ChallengeKind.donut,
    };
  }
}

@JsonEnum()
enum CatalogSection {
  @JsonValue('seasonal')
  seasonal,
  @JsonValue('popular')
  popular,
  @JsonValue('order_again')
  orderAgain;

  static CatalogSection fromName(String name) {
    return switch (name.toLowerCase()) {
      'seasonal' => CatalogSection.seasonal,
      'popular' => CatalogSection.popular,
      'order_again' => CatalogSection.orderAgain,
      'orderagain' => CatalogSection.orderAgain,
      _ => CatalogSection.popular,
    };
  }
}
