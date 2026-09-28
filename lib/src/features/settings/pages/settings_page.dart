import 'package:segmented_list/segmented_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oronbox_lite/src/app/generated/app_localizations.dart';
import 'package:oronbox_lite/src/app/utils/error_localization.dart';
import 'package:oronbox_lite/src/app/window/window_launcher.dart';
import 'package:oronbox_lite/src/app/widgets/sys_app_bar.dart';
import 'package:oronbox_lite/src/app/widgets/dialog_helper.dart';
import 'package:oronbox_lite/src/core/constants/style_constants.dart';
import 'package:oronbox_lite/src/core/providers/app_settings_providers.dart';
import 'package:oronbox_lite/src/core/providers/theme_locale_providers.dart';
import 'package:oronbox_lite/src/core/services/shared_prefs_service.dart';
import 'package:oronbox_lite/src/core/utils/layout.dart';

final _desktopExitBehaviorProvider = Provider<int?>((ref) {
  return SharedPrefsService.instance.getInt('desktop.exit_behavior');
});

enum SettingsCategory { accounts, appearance, connection, support, advanced }

String _categoryTitle(AppLocalizations l10n, SettingsCategory category) =>
    switch (category) {
      SettingsCategory.accounts => l10n.settingsCategoryAccounts,
      SettingsCategory.appearance => l10n.settingsCategoryAppearance,
      SettingsCategory.connection => l10n.settingsCategoryConnection,
      SettingsCategory.support => l10n.settingsCategorySupport,
      SettingsCategory.advanced => l10n.settingsCategoryAdvanced,
    };

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, this.category});

  final SettingsCategory? category;

  /// Stub for removed Mi account login dialog.
  static Future<void> showMiAccountLoginDialog(
    BuildContext context,
    WidgetRef ref, {
    bool forceManual = false,
  }) async {}

  static const _colorSchemes = <Color>[
    Color(0xFFE91E63),
    Color(0xFF6750A4),
    Color(0xFF006A6A),
    Color(0xFF006D3F),
    Color(0xFFB3261E),
    Color(0xFF755B00),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final showDesktopAccentSource =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
    final showWideNavigationPosition = useWideLayout(
      MediaQuery.sizeOf(context).width,
    );
    final showDesktopWindowSettings =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
    final themeSettings = ref.watch(themeSettingsProvider);
    final clean = ref.watch(appSettingsProvider).clean;

    return Scaffold(
      appBar: SysAppBar(
        secondary: category != null,
        title: Text(
          category == null ? l10n.settingsTab : _categoryTitle(l10n, category!),
        ),
      ),
      body: SegmentedList(
        maxWidth: StyleConstants.pageMaxWidth,
        contentPadding: const EdgeInsets.only(top: StyleConstants.pagePadding),
        sections: [
          // Accounts section removed in OronBox-Lite (account modules deleted).
          if (category == null || category == SettingsCategory.appearance)
            _buildSection(
              context,
              title: l10n.settingsGeneral,
              tiles: [
                SegmentedTile.navigation(
                  onPressed: (context) => _showLanguageSelector(context, ref),
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.settingsGeneralLanguage),
                  description: Text(l10n.settingsGeneralLanguageDesc),
                  value: Consumer(
                    builder: (context, ref, _) {
                      final locale = ref.watch(localeSettingsProvider).locale;
                      return Text(_localeLabel(l10n, locale));
                    },
                  ),
                ),
                SegmentedTile.navigation(
                  onPressed: (context) => _showThemeModeSelector(context, ref),
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text(l10n.settingsThemeMode),
                  description: Text(l10n.settingsThemeModeDesc),
                  value: Text(_themeModeLabel(l10n, themeSettings.themeMode)),
                ),
                if (!kIsWeb)
                  SegmentedTile.switchTile(
                    onToggle: (value) async {
                      await ref
                          .read(themeSettingsProvider.notifier)
                          .setDynamicColor(value ?? true);
                    },
                    initialValue: themeSettings.useDynamicColor,
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(l10n.settingsDynamicColor),
                    description: Text(l10n.settingsDynamicColorDesc),
                  ),
                if (!kIsWeb && !themeSettings.useDynamicColor)
                  SegmentedTile.navigation(
                    onPressed: (context) =>
                        _showColorSchemeSelector(context, ref),
                    leading: const Icon(Icons.color_lens_outlined),
                    title: Text(l10n.settingsColorScheme),
                    description: Text(l10n.settingsColorSchemeDesc),
                    value: _ColorDot(color: themeSettings.customSeedColor),
                  ),
                if (showDesktopAccentSource && themeSettings.useDynamicColor)
                  SegmentedTile.navigation(
                    onPressed: (context) =>
                        _showDesktopAccentSourceSelector(context, ref),
                    leading: const Icon(Icons.color_lens_outlined),
                    title: Text(l10n.settingsDesktopAccentSource),
                    description: Text(l10n.settingsDesktopAccentSourceDesc),
                    value: Consumer(
                      builder: (context, ref, _) {
                        final source = ref
                            .watch(themeSettingsProvider)
                            .desktopAccentColorSource;
                        return Text(_desktopAccentSourceLabel(l10n, source));
                      },
                    ),
                  ),
                if (showWideNavigationPosition)
                  SegmentedTile.navigation(
                    onPressed: (context) =>
                        _showWideNavigationPositionSelector(context, ref),
                    leading: const Icon(Icons.vertical_split_outlined),
                    title: Text(l10n.settingsWideNavigationPosition),
                    description: Text(l10n.settingsWideNavigationPositionDesc),
                    value: Consumer(
                      builder: (context, ref, _) {
                        final position = ref
                            .watch(appSettingsProvider)
                            .wideNavigationRailPosition;
                        return Text(
                          _wideNavigationPositionLabel(l10n, position),
                        );
                      },
                    ),
                  ),
                if (showDesktopWindowSettings)
                  SegmentedTile.navigation(
                    onPressed: (context) =>
                        _showDesktopExitBehaviorMenu(context, ref),
                    leading: const Icon(Icons.close_fullscreen_outlined),
                    title: Text(l10n.settingsDesktopCloseBehavior),
                    description: Text(l10n.settingsDesktopCloseBehaviorDesc),
                    value: Text(
                      _desktopExitBehaviorLabel(
                        l10n,
                        ref.watch(_desktopExitBehaviorProvider),
                      ),
                    ),
                  ),
                SegmentedTile.navigation(
                  onPressed: (context) => context.push('/settings/clean-mode'),
                  leading: const Icon(Icons.filter_alt_outlined),
                  title: Text(l10n.cleanMode),
                  description: Text(l10n.cleanModeDescription),
                ),
              ],
            ),
          if (category == null || category == SettingsCategory.connection)
            _buildSection(
              context,
              title: l10n.settingsCategoryConnection,
              tiles: [
                SegmentedTile.switchTile(
                  onToggle: (value) async {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setAutoReconnect(value ?? false);
                  },
                  initialValue: ref.watch(appSettingsProvider).autoReconnect,
                  leading: const Icon(Icons.bluetooth_connected_outlined),
                  title: Text(l10n.settingsAutoReconnectTitle),
                  description: Text(l10n.settingsAutoReconnectDesc),
                ),
                SegmentedTile.switchTile(
                  onToggle: (value) async {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setAutoReconnectOnDisconnect(value ?? false);
                  },
                  initialValue: ref
                      .watch(appSettingsProvider)
                      .autoReconnectOnDisconnect,
                  leading: const Icon(Icons.bluetooth_disabled_outlined),
                  title: Text(l10n.settingsAutoReconnectOnDisconnectTitle),
                  description: Text(l10n.settingsAutoReconnectOnDisconnectDesc),
                ),
                SegmentedTile.switchTile(
                  onToggle: (value) async {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setRemoveBondBeforeSpp(value ?? false);
                  },
                  initialValue: ref
                      .watch(appSettingsProvider)
                      .removeBondBeforeSpp,
                  leading: const Icon(Icons.bluetooth_searching_outlined),
                  title: Text(l10n.settingsRemoveBondBeforeSpp),
                  description: Text(l10n.settingsRemoveBondBeforeSppDesc),
                ),
                SegmentedTile.navigation(
                  onPressed: (context) => _showCdnMenu(context, ref),
                  leading: const Icon(Icons.cloud_outlined),
                  title: Text(l10n.settingsSourceOfficialCdn),
                  description: Text(l10n.settingsSourceOfficialCdnDesc),
                  value: Text(
                    ref.watch(appSettingsProvider).cdn == GitHubCdn.auto
                        ? l10n.settingsGithubCdnAuto
                        : ref.watch(appSettingsProvider).cdn.displayName,
                  ),
                ),
                SegmentedTile.switchTile(
                  onToggle: (value) async {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setAutoInstall(value ?? true);
                  },
                  initialValue: ref.watch(appSettingsProvider).autoInstall,
                  leading: const Icon(Icons.task_alt_outlined),
                  title: Text(l10n.settingsQueueAutoInstall),
                  description: Text(l10n.settingsQueueAutoInstallDesc),
                ),
                SegmentedTile.switchTile(
                  onToggle: (value) async {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setDisableAutoClean(value ?? false);
                  },
                  initialValue: ref.watch(appSettingsProvider).disableAutoClean,
                  leading: const Icon(Icons.playlist_add_check_outlined),
                  title: Text(l10n.settingsQueueDontClear),
                  description: Text(l10n.settingsQueueDontClearDesc),
                ),
                // 鸿蒙端不提供实时活动通知（实况窗是系统受控能力，第三方无法接入）。
                if (defaultTargetPlatform != TargetPlatform.ohos)
                  SegmentedTile.switchTile(
                    onToggle: (value) async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setRealtimeActivityNotification(value ?? true);
                    },
                    initialValue: ref
                        .watch(appSettingsProvider)
                        .realtimeActivityNotification,
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(l10n.settingsRealtimeActivityNotification),
                    description: Text(
                      l10n.settingsRealtimeActivityNotificationDesc,
                    ),
                  ),
              ],
            ),
          if (category == null || category == SettingsCategory.support)
            _buildSection(
              context,
              title: l10n.settingsAbout,
              tiles: [
                SegmentedTile.navigation(
                  onPressed: (_) => context.push('/settings/about'),
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.settingsAboutSoftware),
                  description: Text(l10n.settingsAboutSoftwareDesc),
                ),
                SegmentedTile.navigation(
                  onPressed: (_) => launchUrl(
                    Uri.parse('https://qm.qq.com/q/il3TbmJlKM'),
                    mode: LaunchMode.externalApplication,
                  ),
                  leading: const Icon(Icons.forum_outlined),
                  title: Text(l10n.joinQqGroup),
                  description: Text(l10n.joinQqGroupDesc),
                ),
                SegmentedTile.navigation(
                  onPressed: (_) => context.push('/settings/feedback'),
                  leading: const Icon(Icons.feedback_outlined),
                  title: Text(l10n.feedbackTitle),
                  description: Text(l10n.feedbackDesc),
                ),
                SegmentedTile.navigation(
                  onPressed: (_) => context.push('/settings/advanced'),
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(l10n.settingsCategoryAdvanced),
                  description: Text(l10n.settingsAdvancedDescription),
                ),
              ],
            ),
          if (category == SettingsCategory.advanced)
            _buildSection(
              context,
              title: null,
              tiles: [
                SegmentedTile.navigation(
                  onPressed: (_) => context.push('/oobe?replay=1'),
                  leading: const Icon(Icons.waving_hand_outlined),
                  title: Text(l10n.settingsReplayOobe),
                  description: Text(l10n.settingsReplayOobeDesc),
                ),
                SegmentedTile.navigation(
                  onPressed: (_) => context.push('/settings/logs'),
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(l10n.settingsAboutLogs),
                  description: Text(l10n.settingsAboutLogsDescription),
                ),
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                  SegmentedTile.switchTile(
                    onToggle: (value) => ref
                        .read(xmsDeveloperModeProvider.notifier)
                        .setEnabled(value ?? false),
                    initialValue: ref.watch(xmsDeveloperModeProvider),
                    leading: const Icon(Icons.phonelink_setup_outlined),
                    title: Text(l10n.xmsDeveloperMode),
                    description: Text(l10n.xmsDeveloperModeDescription),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  SegmentedSection _buildSection(
    BuildContext context, {
    required String? title,
    required List<AbstractSegmentedTile> tiles,
  }) {
    return SegmentedSection(
      title: title == null ? null : Text(title),
      tiles: tiles,
    );
  }

  String _localeLabel(AppLocalizations l10n, AppLocale locale) {
    return switch (locale) {
      AppLocale.en => 'English',
      AppLocale.zh => '简体中文',
      AppLocale.zhHant => '繁體中文',
      AppLocale.ja => '日本語',
      AppLocale.ru => 'Русский',
      _ => l10n.settingsSystem,
    };
  }

  String _themeModeLabel(AppLocalizations l10n, AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => l10n.settingsLight,
      AppThemeMode.dark => l10n.settingsDark,
      AppThemeMode.oledDark => l10n.settingsOledDark,
      _ => l10n.settingsSystem,
    };
  }

  String _desktopAccentSourceLabel(
    AppLocalizations l10n,
    DesktopAccentColorSource source,
  ) {
    return switch (source) {
      DesktopAccentColorSource.gtk => l10n.settingsDesktopAccentSourceGtk,
      DesktopAccentColorSource.qt => l10n.settingsDesktopAccentSourceQt,
      _ => l10n.settingsDesktopAccentSourceSystem,
    };
  }

  String _wideNavigationPositionLabel(
    AppLocalizations l10n,
    WideNavigationRailPosition position,
  ) {
    return switch (position) {
      WideNavigationRailPosition.center =>
        l10n.settingsWideNavigationPositionCenter,
      WideNavigationRailPosition.split =>
        l10n.settingsWideNavigationPositionSplit,
      _ => l10n.settingsWideNavigationPositionBottom,
    };
  }

  Future<void> _showCdnMenu(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(appSettingsProvider).cdn;
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );

    final selected = await showMenu<GitHubCdn>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current,
      items: GitHubCdn.values.map((cdn) {
        return PopupMenuItem<GitHubCdn>(
          value: cdn,
          child: Text(
            cdn == GitHubCdn.auto
                ? l10n.settingsGithubCdnAuto
                : cdn.displayName,
          ),
        );
      }).toList(),
    );
    if (selected != null && selected != current) {
      await ref.read(appSettingsProvider.notifier).setCdn(selected);
    }
  }

  Future<void> _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(localeSettingsProvider).locale;
    final l10n = AppLocalizations.of(context)!;
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );

    final selected = await showMenu<AppLocale>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current,
      items: AppLocale.values.map((locale) {
        final selected = locale == current;
        return PopupMenuItem<AppLocale>(
          value: locale,
          child: Row(
            children: [
              Expanded(child: Text(_localeLabel(l10n, locale))),
              if (selected) const Icon(Icons.check),
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null && selected != current) {
      await ref.read(localeSettingsProvider.notifier).setLocale(selected);
    }
  }

  Future<void> _showDesktopAccentSourceSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(themeSettingsProvider).desktopAccentColorSource;
    final l10n = AppLocalizations.of(context)!;
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );

    final selected = await showMenu<DesktopAccentColorSource>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current,
      items: DesktopAccentColorSource.values.map((source) {
        final selected = source == current;
        return PopupMenuItem<DesktopAccentColorSource>(
          value: source,
          child: Row(
            children: [
              Expanded(child: Text(_desktopAccentSourceLabel(l10n, source))),
              if (selected) const Icon(Icons.check),
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null && selected != current) {
      await ref
          .read(themeSettingsProvider.notifier)
          .setDesktopAccentColorSource(selected);
    }
  }

  Future<void> _showThemeModeSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(themeSettingsProvider).themeMode;
    final l10n = AppLocalizations.of(context)!;
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );

    final selected = await showMenu<AppThemeMode>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current,
      items: AppThemeMode.values.map((mode) {
        final selected = mode == current;
        return PopupMenuItem<AppThemeMode>(
          value: mode,
          child: Row(
            children: [
              Expanded(child: Text(_themeModeLabel(l10n, mode))),
              if (selected) const Icon(Icons.check),
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null && selected != current) {
      await ref.read(themeSettingsProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _showColorSchemeSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(themeSettingsProvider).customSeedColor;
    final l10n = AppLocalizations.of(context)!;
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );

    final selected = await showMenu<Color>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current,
      items: _colorSchemes.map((color) {
        final selected = color.toARGB32() == current.toARGB32();
        return PopupMenuItem<Color>(
          value: color,
          child: Row(
            children: [
              _ColorDot(color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(_colorSchemeLabel(l10n, color))),
              if (selected) const Icon(Icons.check),
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null && selected.toARGB32() != current.toARGB32()) {
      await ref
          .read(themeSettingsProvider.notifier)
          .setCustomSeedColor(selected);
    }
  }

  String _colorSchemeLabel(AppLocalizations l10n, Color color) {
    return switch (color.toARGB32()) {
      0xFFE91E63 => l10n.settingsColorSchemePink,
      0xFF6750A4 => l10n.settingsColorSchemePurple,
      0xFF006A6A => l10n.settingsColorSchemeTeal,
      0xFF006D3F => l10n.settingsColorSchemeGreen,
      0xFFB3261E => l10n.settingsColorSchemeRed,
      0xFF755B00 => l10n.settingsColorSchemeAmber,
      _ =>
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    };
  }

  Future<void> _showWideNavigationPositionSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(appSettingsProvider).wideNavigationRailPosition;
    final l10n = AppLocalizations.of(context)!;
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );

    final selected = await showMenu<WideNavigationRailPosition>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current,
      items: WideNavigationRailPosition.values.map((position) {
        final selected = position == current;
        return PopupMenuItem<WideNavigationRailPosition>(
          value: position,
          child: Row(
            children: [
              Expanded(
                child: Text(_wideNavigationPositionLabel(l10n, position)),
              ),
              if (selected) const Icon(Icons.check),
            ],
          ),
        );
      }).toList(),
    );
    if (selected != null && selected != current) {
      await ref
          .read(appSettingsProvider.notifier)
          .setWideNavigationRailPosition(selected);
    }
  }

  Future<void> _showDesktopExitBehaviorMenu(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(_desktopExitBehaviorProvider);
    final tileContext = context;
    final renderBox = tileContext.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(tileContext).overlay?.context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) return;
    final tileTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final tileBottomRight = renderBox.localToGlobal(
      renderBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final anchor = Rect.fromLTWH(
      tileBottomRight.dx - 48,
      tileTopLeft.dy,
      48,
      renderBox.size.height,
    );
    final selected = await showMenu<int>(
      context: tileContext,
      position: RelativeRect.fromRect(anchor, Offset.zero & overlay.size),
      initialValue: current ?? -1,
      items: [
        PopupMenuItem(value: -1, child: Text(l10n.desktopCloseBehaviorAsk)),
        PopupMenuItem(value: 0, child: Text(l10n.desktopCloseBehaviorExit)),
        PopupMenuItem(value: 1, child: Text(l10n.desktopCloseBehaviorTray)),
      ],
    );
    if (selected == null || !context.mounted) return;
    if (selected == -1) {
      await SharedPrefsService.instance.remove('desktop.exit_behavior');
    } else {
      await SharedPrefsService.instance.setInt(
        'desktop.exit_behavior',
        selected,
      );
    }
    ref.invalidate(_desktopExitBehaviorProvider);
  }
}

String _desktopExitBehaviorLabel(AppLocalizations l10n, int? behavior) =>
    switch (behavior) {
      0 => l10n.desktopCloseBehaviorExit,
      1 => l10n.desktopCloseBehaviorTray,
      _ => l10n.desktopCloseBehaviorAsk,
    };

class _AccountLeading extends StatelessWidget {
  const _AccountLeading({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 24, child: Center(child: child));
  }
}

class MiLogo extends StatelessWidget {
  const MiLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsSvgLogo(
      asset: 'assets/images/brands/xiaomi.svg',
      semanticsLabel: 'Xiaomi',
    );
  }
}

class _AccountBrandLogo extends StatelessWidget {
  const _AccountBrandLogo({required this.asset, required this.semanticsLabel});

  final String asset;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return _SettingsSvgLogo(asset: asset, semanticsLabel: semanticsLabel);
  }
}

class _SettingsSvgLogo extends StatelessWidget {
  const _SettingsSvgLogo({required this.asset, required this.semanticsLabel});

  final String asset;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.onSurface,
          BlendMode.srcIn,
        ),
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const SizedBox.square(dimension: 22),
    );
  }
}
