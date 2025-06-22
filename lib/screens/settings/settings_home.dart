/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSpacer rowSpacer = EzSpacer(vertical: false);
  static const EzSeparator separator = EzSeparator();
  static const EzDivider divider = EzDivider();

  late final ButtonStyle menuButtonStyle = TextButton.styleFrom(
    padding: EzInsets.wrap(EzConfig.get(paddingKey)),
  );

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final List<DropdownMenuEntry<AppInfo>> dropdownPackages =
      <AppInfo>[nullApp, ...provider.apps]
          .map((AppInfo app) => DropdownMenuEntry<AppInfo>(
                value: app,
                label: app.label,
                style: menuButtonStyle,
              ))
          .toList();

  final String? leftPackage = EzConfig.get(leftPackageKey);
  final String? rightPackage = EzConfig.get(rightPackageKey);

  late AppInfo leftApp = (leftPackage == null || leftPackage!.isEmpty)
      ? nullApp
      : provider.getAppFromID(leftPackage!) ?? nullApp;
  late AppInfo rightApp = (rightPackage == null || rightPackage!.isEmpty)
      ? nullApp
      : provider.getAppFromID(rightPackage!) ?? nullApp;

  // Full list
  bool autoSearch = EzConfig.get(autoSearchKey) ?? defaultConfig[autoSearchKey];
  bool authToEdit = EzConfig.get(authToEditKey) ?? defaultConfig[authToEditKey];

  // Define custom functions //

  Future<dynamic> showTips() => showPlatformDialog(
        context: context,
        builder: (_) => const EzAlertDialog(
          title: Text('Tips', textAlign: TextAlign.center),
          content: Text('&& tricks', textAlign: TextAlign.center),
        ),
      );

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScreen(
        child: SafeArea(
          child: EzScrollView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  GestureDetector(
                    onLongPress: showTips,
                    child: const EzWarning(
                        'Appearance settings take full effect on restart.\n\nHave fun!'),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: EzIcon(Icons.help_outline),
                      onPressed: showTips,
                    ),
                  ),
                ],
              ), // TODO: semantics && tooltips
              separator,

              // Left swipe
              EzRow(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  EzText('Left package', style: textTheme.bodyLarge),
                  rowSpacer,
                  EzDropdownMenu<AppInfo>(
                    widthEntries: <String>['Play Store'],
                    dropdownMenuEntries: dropdownPackages,
                    initialSelection: leftApp,
                    onSelected: (AppInfo? app) async {
                      if (app == null || app == leftApp) return;

                      await EzConfig.setString(leftPackageKey, app.package);
                      setState(() => leftApp = app);
                    },
                  )
                ],
              ),
              spacer,

              // Right swipe
              EzRow(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  EzText('Right package', style: textTheme.bodyLarge),
                  rowSpacer,
                  EzDropdownMenu<AppInfo>(
                    widthEntries: <String>['Play Store'],
                    dropdownMenuEntries: dropdownPackages,
                    initialSelection: rightApp,
                    onSelected: (AppInfo? app) async {
                      if (app == null || app == rightApp) return;

                      await EzConfig.setString(rightPackageKey, app.package);
                      setState(() => rightApp = app);
                    },
                  )
                ],
              ),
              separator,

              // Auto search
              EzSwitchPair(
                text: 'Auto search',
                value: autoSearch,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(autoSearchKey, value);
                  setState(() => autoSearch = value);
                },
              ),
              spacer,

              // Auto search
              EzSwitchPair(
                text: 'Auth to edit',
                value: authToEdit,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(authToEditKey, value);
                  setState(() => authToEdit = value);
                },
              ),
              divider,

              // GoTo layout settings
              EzElevatedIconButton(
                onPressed: () => context.goNamed(layoutSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.lsPageTitle,
              ),
              spacer,

              // GoTo design settings
              EzElevatedIconButton(
                onPressed: () => context.goNamed(designSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: 'Design settings',
              ),
              spacer,

              // GoTo text settings
              EzElevatedIconButton(
                onPressed: () => context.goNamed(textSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.tsPageTitle,
              ),
              spacer,

              // GoTo color settings
              EzElevatedIconButton(
                onPressed: () => context.goNamed(colorSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.csPageTitle,
              ),
              spacer,

              // GoTo image settings
              EzElevatedIconButton(
                onPressed: () => context.goNamed(imageSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.isPageTitle,
              ),
              divider,

              // Reset
              const EzResetButton(),
              separator,
            ],
          ),
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
