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
  static const EzSpacer rowSpacer = EzSpacer(vertical: false);
  static const EzSeparator separator = EzSeparator();
  static const EzDivider divider = EzDivider();

  final double margin = EzConfig.get(marginKey);
  final double padding = EzConfig.get(paddingKey);
  final double spacing = EzConfig.get(spacingKey);

  late final ButtonStyle menuButtonStyle = TextButton.styleFrom(
    padding: EzInsets.wrap(padding),
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

  LabelType labelType = LabelTypeConfig.fromValue(
      EzConfig.get(labelTypeKey) ?? defaultConfig[labelTypeKey]);
  bool showIcon = EzConfig.get(showIconKey) ?? defaultConfig[showIconKey];

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScreen(
        child: EzScrollView(
          children: <Widget>[
            if (spacing > margin) EzSpacer(space: spacing - margin),
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
            divider,

            // AppTile //

            // Label type
            EzRow(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const EzText('Label type'),
                rowSpacer,
                EzDropdownMenu<LabelType>(
                  widthEntries: <String>['Full name'],
                  dropdownMenuEntries: <DropdownMenuEntry<LabelType>>[
                    const DropdownMenuEntry<LabelType>(
                      value: LabelType.none,
                      label: 'None',
                    ),
                    const DropdownMenuEntry<LabelType>(
                      value: LabelType.initials,
                      label: 'Initials',
                    ),
                    const DropdownMenuEntry<LabelType>(
                      value: LabelType.full,
                      label: 'Full name',
                    ),
                    const DropdownMenuEntry<LabelType>(
                      value: LabelType.wingding,
                      label: 'Wingding',
                    ),
                  ],
                  enableSearch: false,
                  initialSelection: labelType,
                  onSelected: (LabelType? choice) async {
                    if (choice == null) return;
                    await EzConfig.setString(
                      labelTypeKey,
                      choice.configValue,
                    );
                    labelType = choice;

                    if (labelType == LabelType.none) {
                      await EzConfig.setBool(showIconKey, true);
                      showIcon = true;
                    }

                    setState(() {});
                  },
                ),
              ],
            ),
            spacer,

            // Show icon
            EzSwitchPair(
              text: 'Show icon',
              value: homeTime,
              onChanged: (bool? value) async {
                if (value == null) return;

                await EzConfig.setBool(homeTimeKey, value);
                homeTime = value;

                if (value == false && labelType == LabelType.none) {
                  await EzConfig.setString(
                    labelTypeKey,
                    LabelType.full.configValue,
                  );
                  labelType = LabelType.full;
                }

                setState(() {});
              },
            ),
            separator,
          ],
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
