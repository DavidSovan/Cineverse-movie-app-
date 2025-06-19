import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cineverse/shared/providers/connectivity_provider.dart';
import 'package:cineverse/core/screens/offline_screen.dart';

class ConnectivityGuard extends StatelessWidget {
  final Widget child;

  const ConnectivityGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return isOnline ? child : const OfflineScreen();
  }
}
