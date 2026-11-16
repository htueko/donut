import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Which placeholder legal document the [LegalScreen] renders.
enum LegalDocument { terms, privacy }

/// Full-page Terms of Use / Privacy Policy copy. Both documents share the same
/// layout: revision date, intro paragraph and numbered sections.
class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.document, super.key});

  final LegalDocument document;

  bool get _isTerms => document == LegalDocument.terms;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final title = _isTerms
        ? (l10n?.termsOfUse ?? 'Terms of Use')
        : (l10n?.privacyPolicy ?? 'Privacy Policy');
    final sections = <_LegalSection>[
      _LegalSection(
        title: _isTerms
            ? (l10n?.termsSection1Title ?? 'Using the app')
            : (l10n?.privacySection1Title ?? 'What we store'),
        body: _isTerms
            ? (l10n?.termsSection1Body ?? '')
            : (l10n?.privacySection1Body ?? ''),
      ),
      _LegalSection(
        title: _isTerms
            ? (l10n?.termsSection2Title ?? 'Orders and payments')
            : (l10n?.privacySection2Title ?? 'What we do not collect'),
        body: _isTerms
            ? (l10n?.termsSection2Body ?? '')
            : (l10n?.privacySection2Body ?? ''),
      ),
      _LegalSection(
        title: _isTerms
            ? (l10n?.termsSection3Title ?? 'Changes to these terms')
            : (l10n?.privacySection3Title ?? 'Your choices'),
        body: _isTerms
            ? (l10n?.termsSection3Body ?? '')
            : (l10n?.privacySection3Body ?? ''),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Text(
            l10n?.legalUpdated ?? 'Last updated 15 November 2026',
            style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _isTerms ? (l10n?.termsIntro ?? '') : (l10n?.privacyIntro ?? ''),
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          for (final section in sections) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              section.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.h2Weight,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              section.body,
              style: textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}
