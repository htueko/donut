import '../../../l10n/app_localizations.dart';
import '../domain/catalog_enums.dart';

/// Localized display labels for [Tier]. The domain layer stays Flutter-free, so
/// the mapping lives here and callers pass the active [AppLocalizations].
extension TierLabel on Tier {
  String localizedLabel(AppLocalizations? l10n) {
    return switch (this) {
      Tier.bronze => l10n?.tierBronze ?? 'Bronze',
      Tier.silver => l10n?.tierSilver ?? 'Silver',
      Tier.gold => l10n?.tierGold ?? 'Gold',
      Tier.platinum => l10n?.tierPlatinum ?? 'Platinum',
    };
  }
}
