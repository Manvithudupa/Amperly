import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/env/app_env.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_illustration.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../application/auth_validation.dart';
import '../data/auth_repository.dart';

/// Sign in or create the real Supabase account.
///
/// There is no local identity and no demo account. The form only enables when
/// the native build supplied a complete, publishable Supabase configuration.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _createMode = false;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppEnv env = ref.watch(appEnvProvider);
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final bool configured = env.hasSupabase;

    return AmpScaffold(
      wordmark: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceM,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            Text(
              _createMode ? AmpStrings.authCreateTitle : AmpStrings.authTitle,
              style: text.displayLarge,
            ),
            const SizedBox(height: AmpTheme.spaceM),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                _createMode ? AmpStrings.authCreateBody : AmpStrings.authBody,
                style: text.bodyLarge?.copyWith(color: colors.inkSecondary),
              ),
            ),
            const SizedBox(height: AmpTheme.spaceL),
            if (!configured) ...<Widget>[const _SetupNotice()] else ...<Widget>[
              Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (_createMode) ...<Widget>[
                        AmpField(
                          label: AmpStrings.authName,
                          hint: AmpStrings.authNameHint,
                          controller: _name,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const <String>[AutofillHints.name],
                          validator: AuthValidation.name,
                          onChanged: (_) => _clearServerMessage(),
                        ),
                        const SizedBox(height: AmpTheme.spaceM),
                      ],
                      AmpField(
                        label: AmpStrings.authEmail,
                        hint: AmpStrings.authEmailHint,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        validator: AuthValidation.email,
                        onChanged: (_) => _clearServerMessage(),
                      ),
                      const SizedBox(height: AmpTheme.spaceM),
                      AmpField(
                        label: AmpStrings.authPassword,
                        hint: AmpStrings.authPasswordHint,
                        controller: _password,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: <String>[
                          _createMode
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        validator: AuthValidation.password,
                        onChanged: (_) => _clearServerMessage(),
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: AmpTheme.spaceM),
                        _Notice(message: _error!, error: true),
                      ],
                      if (_info != null) ...<Widget>[
                        const SizedBox(height: AmpTheme.spaceM),
                        _Notice(message: _info!, error: false),
                      ],
                      const SizedBox(height: AmpTheme.spaceL),
                      AmpButton(
                        label: _busy
                            ? (_createMode
                                  ? AmpStrings.authCreating
                                  : AmpStrings.authSigningIn)
                            : (_createMode
                                  ? AmpStrings.authCreateAccount
                                  : AmpStrings.authSignIn),
                        loading: _busy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AmpTheme.spaceS),
                      Center(
                        child: AmpButton(
                          label: _createMode
                              ? AmpStrings.authHaveAccount
                              : AmpStrings.authCreatePrompt,
                          variant: AmpButtonVariant.quiet,
                          expand: false,
                          onPressed: _busy ? null : _toggleMode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AmpTheme.spaceL),
            const AmpIllustration(
              AmpIllustrationKind.unpluggedCable,
              width: 172,
              height: 124,
            ),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: AmpTheme.spaceL),
              AmpButton(
                label: AmpStrings.galleryTitle,
                icon: AmpIconName.arrowRight,
                variant: AmpButtonVariant.tonal,
                expand: false,
                onPressed: () => context.go('/gallery'),
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Text(AmpStrings.openGalleryHint, style: text.labelLarge),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _createMode = !_createMode;
      _error = null;
      _info = null;
    });
  }

  void _clearServerMessage() {
    if (_error == null && _info == null) {
      return;
    }
    setState(() {
      _error = null;
      _info = null;
    });
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    FocusScope.of(context).unfocus();
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final AuthRepository? repository = ref.read(authRepositoryProvider);
    if (repository == null) {
      setState(() {
        _error = AmpStrings.configMissingNotice;
        _info = null;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    try {
      final AuthResult result = _createMode
          ? await repository.signUp(
              name: _name.text,
              email: _email.text,
              password: _password.text,
            )
          : await repository.signIn(
              email: _email.text,
              password: _password.text,
            );
      if (!mounted) {
        return;
      }
      if (result.needsEmailConfirmation) {
        setState(() {
          _createMode = false;
          _password.clear();
          _info = AmpStrings.authConfirmEmail(_email.text.trim());
        });
      }
      // A successful sign-in is picked up by the Supabase auth stream and the
      // router's redirect. This screen does not navigate on its own.
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = UserMessages.from(error);
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice();

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return Container(
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AmpBadge(
            AmpStrings.configNotConfigured,
            tone: AmpBadgeTone.warning,
            icon: AmpIconName.alert,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.configMissingNotice,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.error});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color foreground = error ? colors.error : colors.info;
    final Color background = error ? colors.errorTint : colors.infoTint;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: foreground.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmpIcon(
            error ? AmpIconName.alert : AmpIconName.info,
            size: 18,
            color: foreground,
          ),
          const SizedBox(width: AmpTheme.spaceS),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
