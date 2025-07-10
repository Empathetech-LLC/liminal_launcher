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

  bool homeIcon = EzConfig.get(listIconKey) ?? EzConfig.getDefault(listIconKey);
  LabelType listLabelType = LabelTypeConfig.fromValue(
      EzConfig.get(listLabelTypeKey) ?? EzConfig.getDefault(listLabelTypeKey));

  bool folderIcon =
      EzConfig.get(folderIconKey) ?? EzConfig.getDefault(folderIconKey);
  LabelType folderLabelType = LabelTypeConfig.fromValue(
      EzConfig.get(folderLabelTypeKey) ??
          EzConfig.getDefault(folderLabelTypeKey));

  // Define custom functions //

  String listLabel() {
    const String base = 'List App';

    switch (listLabelType) {
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

  String folderLabel() {
    const String base = 'Folder App';

    switch (folderLabelType) {
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
      LiminalScreen(EzScrollView(children: <Widget>[
        if (spacing > margin) EzSpacer(space: spacing - margin),
        // Header //

        // Time
        const EzSwitchPair(text: 'Home time', valueKey: homeTimeKey),
        spacer,

        // Date
        const EzSwitchPair(text: 'Home date', valueKey: homeDateKey),
        // spacer,

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

        // List AppTile //

        // Preview
        homeIcon
            ? EzTextIconButton(
                icon: EzIcon(PlatformIcons(context).settings),
                label: listLabel(),
                onPressed: doNothing,
              )
            : EzTextButton(
                text: listLabel(),
                onPressed: doNothing,
              ),
        spacer,

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
              initialSelection: listLabelType,
              onSelected: (LabelType? choice) async {
                if (choice == null) return;

                await EzConfig.setString(
                  listLabelTypeKey,
                  choice.configValue,
                );
                listLabelType = choice;

                if (listLabelType == LabelType.none) {
                  await EzConfig.setBool(listIconKey, true);
                  homeIcon = true;
                }

                setState(() {});
              },
            ),
          ],
        ),
        rowSpacer,

        // Show icon
        EzSwitchPair(
          text: 'Show icon',
          valueKey: listIconKey,
          onChangedCallback: (bool? value) async {
            if (value == null) return;

            homeIcon = value;
            if (value == false && listLabelType == LabelType.none) {
              await EzConfig.setString(
                listLabelTypeKey,
                LabelType.full.configValue,
              );
              listLabelType = LabelType.full;
            }

            setState(() {});
          },
        ),
        divider,

        // Folder AppTile //
        // Preview
        folderIcon
            ? EzTextIconButton(
                icon: EzIcon(PlatformIcons(context).settings),
                label: folderLabel(),
                onPressed: doNothing,
              )
            : EzTextButton(
                text: folderLabel(),
                onPressed: doNothing,
              ),
        spacer,

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
              initialSelection: folderLabelType,
              onSelected: (LabelType? choice) async {
                if (choice == null) return;

                await EzConfig.setString(
                  folderLabelTypeKey,
                  choice.configValue,
                );
                folderLabelType = choice;

                if (folderLabelType == LabelType.none) {
                  await EzConfig.setBool(folderIconKey, true);
                  folderIcon = true;
                }

                setState(() {});
              },
            ),
          ],
        ),
        rowSpacer,

        // Show icon
        EzSwitchPair(
          text: 'Show icon',
          valueKey: folderIconKey,
          onChangedCallback: (bool? value) async {
            if (value == null) return;

            folderIcon = value;
            if (value == false && folderLabelType == LabelType.none) {
              await EzConfig.setString(
                folderLabelTypeKey,
                LabelType.full.configValue,
              );
              folderLabelType = LabelType.full;
            }

            setState(() {});
          },
        ),
        separator,
      ])),
      fab: EzBackFAB(context),
    );
  }
}
