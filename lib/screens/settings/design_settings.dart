/* empathetech_launcher
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

  //* Return the build *//

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      LiminalScreen(
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
            const EzSwitchPair(text: 'Home weather', valueKey: homeWeatherKey),
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
                    label: 'Preview',
                    onPressed: doNothing,
                  )
                : const EzTextButton(
                    text: 'Preview',
                    onPressed: doNothing,
                  )
          ],
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
