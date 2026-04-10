import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/state/providers.dart';

class AppLifecycleSync extends StatefulWidget {
  final Widget child;
  const AppLifecycleSync({super.key, required this.child});

  @override
  State<AppLifecycleSync> createState() => _AppLifecycleSyncState();
}

class _AppLifecycleSyncState extends State<AppLifecycleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncNotifications();
    }
  }

  Future<void> _syncNotifications() async {
    ProviderContainer? container;
    try {
      container = ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      return;
    }
    final notif = container.read(notificationServiceProvider);
    final db = container.read(databaseProvider);
    await notif.syncAllCounterNotifications(db);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
