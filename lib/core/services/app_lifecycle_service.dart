import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../features/reminder/presentation/providers/reminder_providers.dart';

/// Provider for app initialization state.
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Initialize notification service
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    
    // Request permissions
    await notificationService.requestPermissions();
    
    return true;
  } catch (e) {
    // Log error but don't fail app startup
    debugPrint('App initialization error: $e');
    return false;
  }
});

/// Service for managing app lifecycle and notifications.
class AppLifecycleService extends WidgetBindingObserver {
  final NotificationService _notificationService;
  
  AppLifecycleService(this._notificationService);

  /// Initialize the lifecycle service.
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Dispose the lifecycle service.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        // App went to background
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., during phone call)
        break;
      case AppLifecycleState.hidden:
        // App window is hidden
        break;
    }
  }

  void _onAppResumed() {
    // Handle app resuming from background
    debugPrint('App resumed - checking notification permissions');
    _checkNotificationPermissions();
  }

  void _onAppPaused() {
    // Handle app going to background
    debugPrint('App paused');
    // Could sync data or cleanup resources here
  }

  void _onAppDetached() {
    // Handle app termination
    debugPrint('App detached');
  }

  Future<void> _checkNotificationPermissions() async {
    try {
      await _notificationService.requestPermissions();
    } catch (e) {
      debugPrint('Failed to check notification permissions: $e');
    }
  }
}

/// Provider for app lifecycle service.
final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return AppLifecycleService(notificationService);
});

/// Widget that handles app initialization and lifecycle.
class AppLifecycleWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends ConsumerState<AppLifecycleWrapper> {
  late AppLifecycleService _lifecycleService;

  @override
  void initState() {
    super.initState();
    _lifecycleService = ref.read(appLifecycleServiceProvider);
    _lifecycleService.initialize();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initAsync = ref.watch(appInitializationProvider);

    return initAsync.when(
      data: (initialized) {
        if (!initialized) {
          // Show warning about notification permissions but continue
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPermissionWarning();
          });
        }
        return widget.child;
      },
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Initializing FarmerPulse...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) {
        debugPrint('App initialization error: $error');
        debugPrint('Stack trace: $stack');
        return widget.child; // Continue even if initialization fails
      },
    );
  }

  void _showPermissionWarning() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Enable notifications in settings to receive reminders',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              // TODO: Open app settings
              // This would typically use a plugin like app_settings
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}