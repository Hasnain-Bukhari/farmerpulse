import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// Home / dashboard screen.
///
/// This is the main landing screen after the splash.
/// Add feature cards / quick-access tiles here as the app grows.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.goNamed(AppRouter.settingsName),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SummaryCard(
            icon: Icons.people_outline,
            label: 'Farmers',
            value: '0',
          ),
          SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.agriculture_outlined,
            label: 'Farms',
            value: '0',
          ),
          SizedBox(height: 12),
          _SummaryCard(
            icon: Icons.bar_chart_outlined,
            label: 'Activity',
            value: '0',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add-farmer flow
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Farmer'),
      ),
    );
  }
}

/// A simple stat card used on the home dashboard.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
