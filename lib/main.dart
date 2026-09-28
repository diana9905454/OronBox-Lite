import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oronbox_lite/src/app/oronbox_app.dart';
import 'package:oronbox_lite/src/app/window/desktop_window_bootstrap.dart';
import 'package:oronbox_lite/src/app/window/window_launch_spec.dart';
import 'package:oronbox_lite/src/app/window/window_launcher.dart';
import 'package:oronbox_lite/src/core/logging/logging_service.dart';
import 'package:oronbox_lite/src/core/logging/diagnostic_event.dart';
import 'package:oronbox_lite/src/core/services/bluetooth_permission_bootstrap.dart';
import 'package:oronbox_lite/src/core/services/shared_prefs_service.dart';
import 'package:oronbox_lite/src/host/gui_host_overrides.dart';
import 'package:oronbox_lite/src/features/devices/widgets/device_deep_link_handler.dart';

void main(List<String> args) async {
  final startupStopwatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  final window = WindowLaunchSpec.parse(args);
  await initLogging(arguments: args);
  installGlobalErrorLogging();
  await SharedPrefsService.instance.init();
  if (!await initializeWindowCoordinator(window, launchArguments: args)) return;
  await requestBluetoothPermissionOnStartup();
  await initializeDesktopWindow(spec: window);
  runApp(
    ProviderScope(
      overrides: [
        ...guiHostOverrides(),
        initialDeepLinksProvider.overrideWithValue(args),
      ],
      child: const OronBoxApp(),
    ),
  );
  startupStopwatch.stop();
  logDiagnostic(
    getLogger('Application'),
    Level.INFO,
    'OronBox Lite startup completed',
    fields: {
      'durationMs': startupStopwatch.elapsedMilliseconds,
    },
  );
}
