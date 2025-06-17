/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
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

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  // Top third
  bool homeTime = EzConfig.get(homeTimeKey) ?? defaultConfig[homeTimeKey];
  bool homeDate = EzConfig.get(homeDateKey) ?? defaultConfig[homeDateKey];
  bool homeWeather =
      EzConfig.get(homeWeatherKey) ?? defaultConfig[homeWeatherKey];
  bool hideStatusBar =
      EzConfig.get(hideStatusBarKey) ?? defaultConfig[hideStatusBarKey];

  // Home list
  final List<String> homePackages = EzConfig.getStringList(homePackagesKey) ??
      defaultConfig[homePackagesKey] as List<String>;
  final String? leftPackage = EzConfig.get(leftPackageKey);
  final String? rightPackage = EzConfig.get(rightPackageKey);

  // Full list
  bool autoSearch = EzConfig.get(autoSearchKey) ?? defaultConfig[autoSearchKey];
  List<String>? hiddenPackages = EzConfig.getStringList(hiddenPackagesKey);
  List<String>? nonZenPackages = EzConfig.getStringList(nonZenPackagesKey);
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
              // Functionality disclaimer
              const EzWarning(
                'Changes will take full effect after a restart.\n\nHave fun!',
              ),
              separator,

              // Top third //
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
              const EzSwitchPair(text: 'WeatherPos2Layout', value: false),
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
              separator,

              // Home list //
              const EzSwitchPair(text: 'Home packages', value: true),
              spacer,
              const EzSwitchPair(text: 'HomeAlign2Layout', value: false),
              spacer,
              const EzSwitchPair(text: 'Left package', value: true),
              spacer,
              const EzSwitchPair(text: 'Right package', value: true),
              separator,

              // Full list //
              const EzSwitchPair(text: 'FLAlign2Layout', value: false),
              spacer,
              const EzSwitchPair(text: 'ETile2Design', value: false),
              spacer,
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
              const EzSwitchPair(text: 'Hidden packages', value: true),
              spacer,
              const EzSwitchPair(text: 'Non-zen packages', value: true),
              spacer,
              EzSwitchPair(
                text: 'Zen stream',
                value: zenStream,
                onChanged: (bool? value) async {
                  if (value == null) return;

                  await EzConfig.setBool(zenStreamKey, value);
                  setState(() => zenStream = value);
                },
              ),
              separator,

              // Appearance
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
