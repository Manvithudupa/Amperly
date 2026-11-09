import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/env/app_env.dart';
import '../core/ui/strings.dart';
import '../core/widgets/offline_banner.dart';
import 'router.dart';
import 'theme/amp_theme.dart';

/// The build's configuration, available to screens that must be honest about
/// running without a backend.
final Provider<AppEnv> appEnvProvider = Provider<AppEnv>(
  (Ref ref) => AppEnv.fromEnvironment(),
);

class AmpApp extends ConsumerWidget {
  const AmpApp({super.key});

  static final ThemeData _light = AmpTheme.light();
  static final ThemeData _dark = AmpTheme.dark();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AmpStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: _light,
      darkTheme: _dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) =>
          GlobalOfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
