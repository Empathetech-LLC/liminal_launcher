/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class DesignSettingsScreen extends StatefulWidget {
  const DesignSettingsScreen({super.key});

  @override
  State<DesignSettingsScreen> createState() => _DesignSettingsScreenState();
}

class _DesignSettingsScreenState extends State<DesignSettingsScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSeparator separator = EzSeparator();

  late final ButtonStyle menuButtonStyle = TextButton.styleFrom(
    padding: EzInsets.wrap(EzConfig.get(paddingKey)),
  );

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  bool homeTime = EzConfig.get(homeTimeKey) ?? defaultConfig[homeTimeKey];
  bool homeDate = EzConfig.get(homeDateKey) ?? defaultConfig[homeDateKey];
  bool homeWeather =
      EzConfig.get(homeWeatherKey) ?? defaultConfig[homeWeatherKey];

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScreen(
        child: SafeArea(
          child: EzScrollView(
            children: <Widget>[
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
              separator,
            ],
          ),
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
