/* liminal_launcher
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

  late final EFUILang el10n = ezL10n(context);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final List<DropdownMenuEntry<AppInfo>> swipeEntries =
      <AppInfo>[nullApp, ...provider.apps]
          .map((AppInfo app) => DropdownMenuEntry<AppInfo>(
                value: app,
                label: app.name,
                style: menuButtonStyle,
              ))
          .toList();

  bool resetAll = false;

  // Define custom functions //

  Future<dynamic> showTips() => showPlatformDialog(
        context: context,
        builder: (_) => const EzAlertDialog(
          title: Text('Tips', textAlign: TextAlign.center),
          content: Text('&& tricks', textAlign: TextAlign.center),
        ),
      );

  Future<dynamic> update() => showPlatformDialog(
        context: context,
        builder: (_) => const EzAlertDialog(
          title: Text('Update available', textAlign: TextAlign.center),
          content: Text('BLARG',
              textAlign: TextAlign.center), // TODO: Add a link n shit
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
              // Core
              children: <Widget>[
                GestureDetector(
                  onLongPress: showTips,
                  child: const EzWarning(
                      'Appearance settings take full effect on restart.\n\nHave fun!'),
                ),

                // Tips
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: EzIcon(Icons.help_outline),
                    onPressed: showTips,
                  ),
                ),

                // Updater (if relevant)
                const Positioned(top: 0, left: 0, child: EzUpdater()),
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
            spacer,

            // Auto add to home
            const EzSwitchPair(
              text: 'Add new apps to home',
              valueKey: autoAddToHomeKey,
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

            // Randomize
            EzConfigRandomizer(
              dialogContent:
                  'Only affects appearance settings\n${el10n.gUndoWarn}',
              onConfirm: () async {
                await EzConfig.randomize(isDarkTheme(context), shiny: false);

                final Random random = Random();

                // Layout

                final int homeAlignRand = random.nextInt(3);
                late final String homeAlignValue;
                switch (homeAlignRand) {
                  case 1:
                    homeAlignValue = ListAlignment.start.configValue;
                    break;
                  case 2:
                    homeAlignValue = ListAlignment.end.configValue;
                    break;
                  default:
                    homeAlignValue = ListAlignment.center.configValue;
                    break;
                }
                await EzConfig.setString(homeAlignmentKey, homeAlignValue);

                final int listAlignRand = random.nextInt(3);
                late final String listAlignValue;
                switch (listAlignRand) {
                  case 1:
                    listAlignValue = ListAlignment.start.configValue;
                    break;
                  case 2:
                    listAlignValue = ListAlignment.end.configValue;
                    break;
                  default:
                    listAlignValue = ListAlignment.center.configValue;
                    break;
                }
                await EzConfig.setString(fullListAlignmentKey, listAlignValue);

                // Design

                await EzConfig.setBool(homeTimeKey, random.nextBool());
                await EzConfig.setBool(homeDateKey, random.nextBool());

                // final bool headerOrder = random.nextBool();
                // await EzConfig.setString(
                //   headerOrderKey,
                //   ((headerOrder == true)
                //           ? HeaderOrder.timeFirst
                //           : HeaderOrder.weatherFirst)
                //       .configValue,
                // );

                await EzConfig.setBool(homeIconKey, random.nextBool());
                final int listLabelRand = random.nextInt(4);
                late final String listLabelValue;
                switch (listLabelRand) {
                  case 0:
                    listLabelValue = LabelType.none.configValue;
                    break;
                  case 1:
                    listLabelValue = LabelType.initials.configValue;
                    break;
                  case 3:
                    listLabelValue = LabelType.wingding.configValue;
                    break;
                  default:
                    listLabelValue = LabelType.full.configValue;
                    break;
                }
                await EzConfig.setString(listLabelTypeKey, listLabelValue);

                await EzConfig.setBool(folderIconKey, random.nextBool());
                final int folderLabelRand = random.nextInt(3);
                late final String folderLabelValue;
                switch (folderLabelRand) {
                  case 0:
                    folderLabelValue = LabelType.none.configValue;
                    break;
                  case 1:
                    folderLabelValue = LabelType.initials.configValue;
                    break;
                  case 3:
                    folderLabelValue = LabelType.wingding.configValue;
                  default:
                    folderLabelValue = LabelType.full.configValue;
                    break;
                }
                await EzConfig.setString(folderLabelTypeKey, folderLabelValue);
              },
            ),
            spacer,

            // Reset
            EzElevatedIconButton(
              onPressed: () => showPlatformDialog(
                context: context,
                builder: (_) => StatefulBuilder(builder: (
                  BuildContext dialogContext,
                  StateSetter dialogState,
                ) {
                  late final Set<String> skip = <String>{
                    homeIDsKey,
                    hiddenIDsKey,
                    leftAppKey,
                    rightAppKey,
                    authToEditKey,
                  };

                  late final List<Widget> materialActions;
                  late final List<Widget> cupertinoActions;

                  (materialActions, cupertinoActions) = ezActionPairs(
                    context: context,
                    onConfirm: () async {
                      await EzConfig.reset(skip: resetAll ? <String>{} : skip);
                      if (resetAll) await provider.reset();

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    confirmIsDestructive: true,
                    onDeny: () => Navigator.of(dialogContext).pop(),
                  );

                  return EzAlertDialog(
                    key: ValueKey<bool>(resetAll),
                    title: const Text(
                      'Reset all appearance settings?',
                      textAlign: TextAlign.center,
                    ),
                    contents: <Widget>[
                      EzSwitchPair(
                        text: 'Or, ALL settings',
                        value: resetAll,
                        onChanged: (bool? choice) {
                          resetAll = (choice == null) ? false : choice;
                          setState(() {});
                          dialogState(() {});
                        },
                      ),
                      spacer,
                      Text(
                        el10n.gUndoWarn,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    materialActions: materialActions,
                    cupertinoActions: cupertinoActions,
                    needsClose: false,
                  );
                }),
              ),
              icon: EzIcon(PlatformIcons(context).refresh),
              label: el10n.gResetAll,
            ),
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

  late final String? leftID = EzConfig.get(leftAppKey);
  late final String? rightID = EzConfig.get(rightAppKey);

  late AppInfo leftApp = (leftID == null || leftID!.isEmpty)
      ? nullApp
      : widget.provider.appMap[leftID!] ?? nullApp;
  late AppInfo rightApp = (rightID == null || rightID!.isEmpty)
      ? nullApp
      : widget.provider.appMap[rightID!] ?? nullApp;

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

                  await EzConfig.setString(leftAppKey, app.id);
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

                  await EzConfig.setString(rightAppKey, app.id);
                  setState(() => rightApp = app);
                },
              )
            ],
    );
  }
}
