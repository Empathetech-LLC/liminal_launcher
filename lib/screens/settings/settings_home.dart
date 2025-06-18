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

  late final ButtonStyle menuButtonStyle = TextButton.styleFrom(
    padding: EzInsets.wrap(EzConfig.get(paddingKey)),
  );

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  // Header
  bool homeTime = EzConfig.get(homeTimeKey) ?? defaultConfig[homeTimeKey];
  bool homeDate = EzConfig.get(homeDateKey) ?? defaultConfig[homeDateKey];
  bool homeWeather =
      EzConfig.get(homeWeatherKey) ?? defaultConfig[homeWeatherKey];
  bool hideStatusBar =
      EzConfig.get(hideStatusBarKey) ?? defaultConfig[hideStatusBarKey];

  // Home list
  final List<String> homePackages = EzConfig.get(homePackagesKey) ??
      defaultConfig[homePackagesKey] as List<String>;
  late final List<String> appNames =
      provider.apps.map((AppInfo app) => app.label).toList();

  late final List<DropdownMenuEntry<AppInfo>> dropdownPackages =
      <AppInfo>[nullApp, ...provider.apps]
          .map((AppInfo app) => DropdownMenuEntry<AppInfo>(
                value: app,
                label: app.label,
                style: menuButtonStyle,
              ))
          .toList();

  final String storedLeft = EzConfig.get(leftPackageKey) ?? '';
  final String storedRight = EzConfig.get(rightPackageKey) ?? '';

  late AppInfo leftPackage = dropdownPackages
      .firstWhere((DropdownMenuEntry<AppInfo> entry) =>
          entry.value.package == storedLeft)
      .value; // TODO: faster
  late AppInfo rightPackage = dropdownPackages
      .firstWhere((DropdownMenuEntry<AppInfo> entry) =>
          entry.value.package == storedRight)
      .value; // TODO: faster

  // Full list
  bool autoSearch = EzConfig.get(autoSearchKey) ?? defaultConfig[autoSearchKey];
  List<String>? hiddenPackages = EzConfig.get(hiddenPackagesKey);
  List<String>? nonZenPackages = EzConfig.get(nonZenPackagesKey);
  bool zenStream = EzConfig.get(zenStreamKey) ?? defaultConfig[zenStreamKey];

  //* Return the build *//
  // TODO: Should some of these go into custom pre-existing screens?
  // Example: Home alignment in layout settings

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      SafeArea(
        child: EzScreen(
          child: EzScrollView(
            children: <Widget>[
              const EzWarning(
                'Changes will take full effect after a restart.\n\nHave fun!',
              ),
              separator,

              // Header //

              // Time
              EzSwitchPair(
                text: 'Home time',
                value: homeTime,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(homeTimeKey, value);
                  setState(() => homeTime = value);
                },
              ),
              spacer,

              // Date
              EzSwitchPair(
                text: 'Home date',
                value: homeDate,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(homeDateKey, value);
                  setState(() => homeDate = value);
                },
              ),
              spacer,

              // Weather
              EzSwitchPair(
                text: 'Home weather',
                value: homeWeather,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(homeWeatherKey, value);
                  setState(() => homeWeather = value);
                },
              ),
              spacer,

              // tmp
              const EzText('WeatherPos2Layout'),
              spacer,
              EzSwitchPair(
                text: 'Hide status bar',
                value: hideStatusBar,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(hideStatusBarKey, value);
                  setState(() => hideStatusBar = value);
                },
              ),
              divider,

              // Home list //

              // Home list
              const EzText('HomePackages2Home'),
              spacer,

              // tmp
              const EzText('HomeAlign2Layout'),
              spacer,

              // Left swipe
              EzRow(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  EzText('Left package', style: textTheme.bodyLarge),
                  spacer,
                  EzDropdownMenu<AppInfo>(
                    widthEntries: appNames,
                    dropdownMenuEntries: dropdownPackages,
                    initialSelection: leftPackage,
                    onSelected: (AppInfo? app) async {
                      if (app == null || app == leftPackage) return;

                      await EzConfig.setString(leftPackageKey, app.package);
                      setState(() => leftPackage = app);
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
                  spacer,
                  EzDropdownMenu<AppInfo>(
                    widthEntries: appNames,
                    dropdownMenuEntries: dropdownPackages,
                    initialSelection: rightPackage,
                    onSelected: (AppInfo? app) async {
                      if (app == null || app == rightPackage) return;

                      await EzConfig.setString(rightPackageKey, app.package);
                      setState(() => rightPackage = app);
                    },
                  )
                ],
              ),
              divider,

              // Full list //

              // tmp
              const EzText('FLAlign2Layout'),
              spacer,

              // tmp
              const EzText('ETile2Design'),
              spacer,

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

              // Always hidden packages
              const EzSwitchPair(text: 'Hidden packages', value: true),
              spacer,

              // Always quarantined packages
              const EzSwitchPair(text: 'Quarantined packages', value: true),
              spacer,

              // Packages hidden during focus
              const EzSwitchPair(text: 'Non-zen packages I', value: true),
              spacer,

              // Packages quarantined during focus
              const EzSwitchPair(text: 'Non-zen packages II', value: true),
              separator,

              // Navigation //

              EzElevatedIconButton(
                onPressed: () => context.goNamed(ezSettingsHomePath),
                icon: EzIcon(Icons.navigate_next),
                label: 'Appearance settings',
              ),
              separator,
            ],
          ),
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
