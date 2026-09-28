import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oronbox_lite/src/app/generated/app_localizations.dart';
import 'package:oronbox_lite/src/app/widgets/app_error_gate.dart';
import 'package:oronbox_lite/src/core/providers/app_settings_providers.dart';

final appDioProvider = Provider<Dio>((ref) {
  return createAppHttpTransport(
    githubCdn: () => ref.read(appSettingsProvider).effectiveCdn,
    onGithubCdnFallback: (fallback) {
      final messenger = appScaffoldMessengerKey.currentState;
      final context = appScaffoldMessengerKey.currentContext;
      if (messenger == null || context == null) return;
      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.githubCdnFallback(fallback.displayName)),
        ),
      );
    },
  );
});
