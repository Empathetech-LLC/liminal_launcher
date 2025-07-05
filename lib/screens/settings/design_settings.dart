/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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

  LabelType labelType = LabelTypeConfig.fromValue(
      EzConfig.get(labelTypeKey) ?? EzConfig.getDefault(labelTypeKey));

  bool showIcon = EzConfig.get(showIconKey) ?? EzConfig.getDefault(showIconKey);

  // Define custom functions //

  String label() {
    const String base = 'App Preview';

    switch (labelType) {
      case LabelType.none:
        return '';

      case LabelType.initials:
        return base
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();

      case LabelType.full:
        return base;

      case LabelType.wingding:
        return base
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
    }
  }

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
            const EzSwitchPair(text: 'Home time', valueKey: homeTimeKey),
            spacer,

            // Date
            const EzSwitchPair(text: 'Home date', valueKey: homeDateKey),
            spacer,

            // Weather
            // EzSwitchPair(
            //   text: 'Home weather',
            //   valueKey: homeWeatherKey,
            //   canChange: (bool choice) async {
            //     return choice
            //         ? await showPlatformDialog<bool>(
            //               context: context,
            //               builder: (_) => const EzAlertDialog(
            //                 title: Text('API key'),
            //                 content: Text('GIVE TO ME'),
            //               ),
            //             ) ??
            //             false
            //         : true;
            //   },
            // ),
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
              valueKey: showIconKey,
              onChangedCallback: (bool? value) async {
                if (value == null) return;

                showIcon = value;
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

            // Preview
            showIcon
                ? EzTextIconButton(
                    icon: EzIcon(PlatformIcons(context).settings),
                    label: label(),
                    onPressed: doNothing,
                  )
                : EzTextButton(
                    text: label(),
                    onPressed: doNothing,
                  )
          ],
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
