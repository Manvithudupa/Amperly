import 'package:flutter/material.dart';

import '../core/env/app_env.dart';
import '../core/ui/strings.dart';
import '../core/widgets/amp_illustration.dart';
import '../core/widgets/error_state.dart';
import 'theme/amp_theme.dart';

/// Shown instead of the app when the build settings are unsafe or incomplete.
///
/// It deliberately contains no key, URL or exception text: a configuration
/// failure must not become a leak. The developer gets a written instruction.
class ConfigurationErrorApp extends StatelessWidget {
  const ConfigurationErrorApp({required this.problem, super.key});

  final ConfigurationProblem problem;

  @override
  Widget build(BuildContext context) {
    final (String title, String message) = switch (problem) {
      ConfigurationProblem.secretKey => (
        AmpStrings.configSecretTitle,
        AmpStrings.configSecretBody,
      ),
      ConfigurationProblem.incompleteSupabase => (
        AmpStrings.configMissingTitle,
        AmpStrings.configMissingBody,
      ),
      ConfigurationProblem.backendUnavailable => (
        AmpStrings.configBackendTitle,
        AmpStrings.configBackendBody,
      ),
    };

    return MaterialApp(
      title: AmpStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AmpTheme.light(),
      darkTheme: AmpTheme.dark(),
      home: Scaffold(
        body: SafeArea(
          child: ErrorState(
            title: title,
            message: message,
            illustration: AmpIllustrationKind.offline,
          ),
        ),
      ),
    );
  }
}
