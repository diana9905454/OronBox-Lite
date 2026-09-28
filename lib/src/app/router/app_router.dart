import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oronbox_lite/src/app/layout/app_navigation_bar.dart';
import 'package:oronbox_lite/src/app/layout/app_scaffold.dart';
import 'package:oronbox_lite/src/app/theme/app_theme.dart';
import 'package:oronbox_lite/src/app/widgets/dialog_helper.dart';
import 'package:oronbox_lite/src/core/providers/app_settings_providers.dart';
import 'package:oronbox_lite/src/features/devices/pages/apps/device_apps_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/devices_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/firmware/device_firmware_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/info/device_info_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/install/install_local_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/zeppos_more_features_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/zeppos_xiao_ai_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/zeppos_app_side_debug_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/zeppos_app_settings_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/zeppos_music_upload_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/xiaomi_recordings_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/xiaomi_health_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/xiaomi_health_detail_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/xiaomi_device_settings_pages.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/xiaomi_device_feature_pages.dart';
import 'package:oronbox_lite/src/features/devices/pages/more/zeppos_voice_memos_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/switch/device_switch_page.dart';
import 'package:oronbox_lite/src/features/oobe/oobe_state.dart';
import 'package:oronbox_lite/src/features/oobe/pages/oobe_page.dart';
import 'package:oronbox_lite/src/features/devices/pages/watchfaces/device_watchfaces_page.dart';
import 'package:oronbox_lite/src/features/devices/providers/pending_shared_device_provider.dart';
import 'package:oronbox_lite/src/features/devices/services/device_share_link.dart';
import 'package:oronbox_lite/src/features/settings/pages/acknowledgements_page.dart';
import 'package:oronbox_lite/src/features/settings/pages/about_software_page.dart';
import 'package:oronbox_lite/src/features/settings/pages/settings_page.dart';
import 'package:oronbox_lite/src/features/settings/pages/clean_mode_page.dart';
import 'package:oronbox_lite/src/features/settings/pages/legal_documents_page.dart';
import 'package:oronbox_lite/src/features/messages/pages/inbox_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/devices',
    observers: [OronBoxDialog.observer],
    redirect: (context, state) {
      final uri = state.uri;
      final onOobe = uri.path == '/oobe';
      if (!isOobeCompleted()) {
        return onOobe ? null : '/oobe';
      }
      if (onOobe && uri.queryParameters['replay'] != '1') {
        return '/devices';
      }
      final clean = ref.read(appSettingsProvider).clean;
      if (uri.path == '/inbox' && !clean.inboxEnabled) {
        return '/devices';
      }
      final isDeviceShareLink =
          (uri.scheme == 'oronbox' && uri.host == 'open') ||
          ((uri.scheme == 'https' || uri.scheme == 'http') &&
              uri.host == 'oronbox.zxor.org' &&
              uri.path == '/open');
      if (!isDeviceShareLink) return null;

      final device = DeviceShareLink.parse(uri.toString());
      if (device != null) {
        ref.read(pendingSharedDeviceProvider.notifier).set(device);
        return '/devices/switch';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/oobe', builder: (context, state) => const OobePage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/devices',
                builder: (context, state) => const PrimaryBranchScaffold(
                  child: DevicesPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'switch',
                    builder: (context, state) => const DeviceSwitchPage(),
                  ),
                  GoRoute(
                    path: 'info',
                    builder: (context, state) => const DeviceInfoPage(),
                  ),
                  GoRoute(
                    path: 'firmware',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      transitionDuration: const Duration(milliseconds: 320),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 300,
                      ),
                      child: const DeviceFirmwarePage(),
                      transitionsBuilder: AppTheme.buildPlatformPageTransition,
                    ),
                  ),
                  GoRoute(
                    path: 'install/:type',
                    builder: (context, state) {
                      final typeName = state.pathParameters['type']!;
                      final type = InstallType.values.firstWhere(
                        (e) => e.name == typeName,
                        orElse: () => InstallType.app,
                      );
                      return InstallLocalPage(type: type);
                    },
                  ),
                  GoRoute(
                    path: 'apps',
                    builder: (context, state) => const DeviceAppsPage(),
                  ),
                  GoRoute(
                    path: 'watchfaces',
                    builder: (context, state) => const DeviceWatchfacesPage(),
                  ),
                  GoRoute(
                    path: 'velaos-music',
                    builder: (context, state) =>
                        const DeviceMusicUploadPage(xiaomi: true),
                  ),
                  GoRoute(
                    path: 'velaos-recordings',
                    builder: (context, state) => const XiaomiRecordingsPage(),
                  ),
                  GoRoute(
                    path: 'velaos-health',
                    builder: (context, state) => const XiaomiHealthPage(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        builder: (context, state) {
                          final args = state.extra;
                          if (args is! XiaomiHealthDetailArgs) {
                            return const XiaomiHealthPage();
                          }
                          return XiaomiHealthDetailPage(args: args);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'velaos-app-layout',
                    builder: (context, state) => const XiaomiAppLayoutPage(),
                  ),
                  GoRoute(
                    path: 'velaos-app-order',
                    builder: (context, state) => const XiaomiAppOrderPage(),
                  ),
                  GoRoute(
                    path: 'velaos-alarms',
                    builder: (context, state) => const XiaomiAlarmsPage(),
                  ),
                  GoRoute(
                    path: 'velaos-weather',
                    builder: (context, state) => const XiaomiWeatherPage(),
                  ),
                  GoRoute(
                    path: 'zeppos-more',
                    builder: (context, state) => const ZeppOsMoreFeaturesPage(),
                    routes: [
                      GoRoute(
                        path: 'xiao-ai',
                        builder: (context, state) => const ZeppOsXiaoAiPage(),
                      ),
                      GoRoute(
                        path: 'voice-memos',
                        builder: (context, state) =>
                            const ZeppOsVoiceMemosPage(),
                      ),
                      GoRoute(
                        path: 'music',
                        builder: (context, state) =>
                            const DeviceMusicUploadPage(),
                      ),
                      GoRoute(
                        path: 'app-side',
                        builder: (context, state) =>
                            const ZeppOsAppSideDebugPage(),
                      ),
                      GoRoute(
                        path: 'settings',
                        builder: (context, state) =>
                            const ZeppOsAppSettingsPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const PrimaryBranchScaffold(
                  child: SettingsPage(),
                ),
                routes: [
                  for (final category in SettingsCategory.values)
                    GoRoute(
                      path: category.name,
                      builder: (context, state) =>
                          SettingsPage(category: category),
                    ),
                  GoRoute(
                    path: 'clean-mode',
                    builder: (context, state) => const CleanModePage(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutSoftwarePage(),
                  ),
                  GoRoute(
                    path: 'legal/:id',
                    builder: (context, state) => LegalDocumentPage(
                      id: state.pathParameters['id']!,
                      title: state.extra?.toString() ?? '',
                    ),
                  ),
                  GoRoute(
                    path: 'logs',
                    builder: (context, state) => const RuntimeLogsPage(),
                  ),
                  GoRoute(
                    path: 'team',
                    redirect: (context, state) => '/settings/about',
                  ),
                  GoRoute(
                    path: 'acknowledgements',
                    builder: (context, state) => const AcknowledgementsPage(),
                  ),
                  GoRoute(
                    path: 'licenses',
                    builder: (context, state) =>
                        const LicensePage(applicationName: 'OronBox Lite'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
