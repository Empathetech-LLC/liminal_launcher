/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'dart:math';
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
  static const EzSeparator separator = EzSeparator();
  static const EzDivider divider = EzDivider();

  final EzSpacer margin = EzMargin();

  late final ButtonStyle menuButtonStyle = TextButton.styleFrom(
    padding: EzInsets.wrap(EzConfig.get(paddingKey)),
  );

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final List<DropdownMenuEntry<AppInfo>> swipeEntries =
      <AppInfo>[nullApp, ...provider.apps]
          .map((AppInfo app) => DropdownMenuEntry<AppInfo>(
                value: app,
                label: app.label,
                style: menuButtonStyle,
              ))
          .toList();

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
      LiminalScreen(
        child: EzScrollView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                GestureDetector(
                  onLongPress: showTips,
                  child: const EzWarning(
                      'Most appearance settings take full effect on restart.\n\nHave fun!'),
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
            ),
            separator,

            // Left swipe
            _SwipeSelector(
              isLefty: true,
              entries: swipeEntries,
              provider: provider,
              textTheme: textTheme,
            ),
            spacer,

            // Right swipe
            _SwipeSelector(
              isLefty: false,
              entries: swipeEntries,
              provider: provider,
              textTheme: textTheme,
            ),
            separator,

            // Auto search
            const EzSwitchPair(text: 'Auto search', valueKey: autoSearchKey),
            spacer,

            // Auto search
            const EzSwitchPair(text: 'Auth to edit', valueKey: authToEditKey),
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

            // Randomize
            EzConfigRandomizer(
              dialogContent:
                  'Only affects appearance settings\n${el10n.gUndoWarn}',
              onConfirm: () async {
                await EzConfig.randomize(isDarkTheme(context), shiny: false);

                final Random random = Random();
                await EzConfig.setBool(homeTimeKey, random.nextBool());
                await EzConfig.setBool(homeDateKey, random.nextBool());
                await EzConfig.setBool(showIconKey, random.nextBool());

                final bool headerOrder = random.nextBool();
                await EzConfig.setString(
                  headerOrderKey,
                  ((headerOrder == true)
                          ? HeaderOrder.timeFirst
                          : HeaderOrder.weatherFirst)
                      .configValue,
                );

                final int homeAlignRand = random.nextInt(3);
                late final String homeAlignValue;
                switch (homeAlignRand) {
                  case 0:
                    homeAlignValue = ListAlignment.start.configValue;
                    break;
                  case 2:
                    homeAlignValue = ListAlignment.end.configValue;
                    break;
                  default:
                    homeAlignValue = ListAlignment.center.configValue;
                }
                await EzConfig.setString(homeAlignmentKey, homeAlignValue);

                final int listAlignRand = random.nextInt(3);
                late final String listAlignValue;
                switch (listAlignRand) {
                  case 0:
                    listAlignValue = ListAlignment.start.configValue;
                    break;
                  case 2:
                    listAlignValue = ListAlignment.end.configValue;
                    break;
                  default:
                    listAlignValue = ListAlignment.center.configValue;
                }
                await EzConfig.setString(fullListAlignmentKey, listAlignValue);
              },
            ),
            spacer,

            // Reset
            const EzResetButton(skip: <String>{
              homePackagesKey,
              hiddenPackagesKey,
              leftPackageKey,
              rightPackageKey,
              authToEditKey,
            }),
            separator,
          ],
        ),
      ),
      fab: EzBackFAB(context, showHome: true),
    );
  }
}

class _SwipeSelector extends StatefulWidget {
  final bool isLefty;
  final List<DropdownMenuEntry<AppInfo>> entries;
  final AppInfoProvider provider;
  final TextTheme textTheme;

  const _SwipeSelector({
    required this.isLefty,
    required this.entries,
    required this.provider,
    required this.textTheme,
  });

  @override
  State<_SwipeSelector> createState() => _SwipeSelectorState();
}

class _SwipeSelectorState extends State<_SwipeSelector> {
  late final String leftLabel = 'Left package';
  late final String rightLabel = 'Right package';

  late final String? leftPackage = EzConfig.get(leftPackageKey);
  late final String? rightPackage = EzConfig.get(rightPackageKey);

  late AppInfo leftApp = (leftPackage == null || leftPackage!.isEmpty)
      ? nullApp
      : widget.provider.getAppFromID(leftPackage!) ?? nullApp;
  late AppInfo rightApp = (rightPackage == null || rightPackage!.isEmpty)
      ? nullApp
      : widget.provider.getAppFromID(rightPackage!) ?? nullApp;

  @override
  Widget build(BuildContext context) {
    return EzRow(
      mainAxisSize: MainAxisSize.min,
      children: widget.isLefty
          ? <Widget>[
              EzText(leftLabel, style: widget.textTheme.bodyLarge),
              EzMargin(),
              EzDropdownMenu<AppInfo>(
                widthEntries: <String>['Play Store'],
                dropdownMenuEntries: widget.entries,
                initialSelection: leftApp,
                onSelected: (AppInfo? app) async {
                  if (app == null || app == leftApp) return;

                  await EzConfig.setString(leftPackageKey, app.package);
                  setState(() => leftApp = app);
                },
              )
            ]
          : <Widget>[
              EzText(rightLabel, style: widget.textTheme.bodyLarge),
              EzMargin(),
              EzDropdownMenu<AppInfo>(
                widthEntries: <String>['Play Store'],
                dropdownMenuEntries: widget.entries,
                initialSelection: rightApp,
                onSelected: (AppInfo? app) async {
                  if (app == null || app == rightApp) return;

                  await EzConfig.setString(rightPackageKey, app.package);
                  setState(() => rightApp = app);
                },
              )
            ],
    );
  }
}
