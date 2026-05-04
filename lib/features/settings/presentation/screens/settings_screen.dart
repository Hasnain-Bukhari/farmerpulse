import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/locale_provider.dart';

/// Settings screen — currently exposes language selection.
///
/// Extend with theme switcher, notification toggles, etc.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ── Language ──────────────────────────────────────────────────────
          const _SectionHeader(title: 'Language'),
          _LanguageTile(
            language: 'English',
            languageCode: AppConstants.localeEn,
            isSelected: currentLocale.languageCode == AppConstants.localeEn,
            onTap: () => ref
                .read(localeProvider.notifier)
                .setLocale(AppConstants.localeEn),
          ),
          _LanguageTile(
            language: 'اردو (Urdu)',
            languageCode: AppConstants.localeUr,
            isSelected: currentLocale.languageCode == AppConstants.localeUr,
            onTap: () => ref
                .read(localeProvider.notifier)
                .setLocale(AppConstants.localeUr),
          ),

          const Divider(),

          // ── About ─────────────────────────────────────────────────────────
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            trailing: const Text('1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final String language;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(language),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
