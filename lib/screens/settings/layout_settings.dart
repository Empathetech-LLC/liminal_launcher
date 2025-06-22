/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LayoutSettingsScreen extends StatefulWidget {
  const LayoutSettingsScreen({super.key});

  @override
  State<LayoutSettingsScreen> createState() => _LayoutSettingsScreenState();
}

class _LayoutSettingsScreenState extends State<LayoutSettingsScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSpacer rowSpacer = EzSpacer(vertical: false);
  static const EzSeparator separator = EzSeparator();
  static const EzDivider divider = EzDivider();

  // Define the build data //

  HeaderOrder headerOrder = HeaderOrderConfig.fromValue(
    EzConfig.get(headerOrderKey) ?? EzConfig.getDefault(headerOrderKey),
  );

  ListAlignment homeAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(homeAlignmentKey) ?? EzConfig.getDefault(homeAlignmentKey),
  );
  late MainAxisAlignment homeAxis = homeAlign.axisValue;
  late TextAlign homeText = homeAlign.textValue;

  ListAlignment fullAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(fullListAlignmentKey) ??
        EzConfig.getDefault(fullListAlignmentKey),
  );
  late MainAxisAlignment fullAxis = fullAlign.axisValue;
  late TextAlign fullText = fullAlign.textValue;

  // Define custom Widgets //

  static const List<ButtonSegment<ListAlignment>> alignmentSegments =
      <ButtonSegment<ListAlignment>>[
    ButtonSegment<ListAlignment>(
      value: ListAlignment.start,
      label: Text('Start', textAlign: TextAlign.center),
    ),
    ButtonSegment<ListAlignment>(
      value: ListAlignment.center,
      label: Text('Center', textAlign: TextAlign.center),
    ),
    ButtonSegment<ListAlignment>(
      value: ListAlignment.end,
      label: Text('End', textAlign: TextAlign.center),
    ),
  ];

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      SafeArea(
        child: EzLayoutSettings(
          beforeLayout: <Widget>[const EzDominantHandSwitch()],
          prefixSpacer: spacer,
          postfixSpacer: divider,
          afterLayout: <Widget>[
            EzRow(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const EzText('Header order'),
                rowSpacer,
                EzDropdownMenu<HeaderOrder>(
                  widthEntries: <String>['Weather first'],
                  dropdownMenuEntries: <DropdownMenuEntry<HeaderOrder>>[
                    const DropdownMenuEntry<HeaderOrder>(
                      value: HeaderOrder.timeFirst,
                      label: 'Time first',
                    ),
                    const DropdownMenuEntry<HeaderOrder>(
                      value: HeaderOrder.weatherFirst,
                      label: 'Weather first',
                    ),
                  ],
                  enableSearch: false,
                  initialSelection: headerOrder,
                  onSelected: (HeaderOrder? choice) async {
                    if (choice == null) return;
                    await EzConfig.setString(
                      headerOrderKey,
                      choice.configValue,
                    );
                    setState(() => headerOrder = choice);
                  },
                ),
              ],
            ),
            separator,

            // Home align
            SizedBox(
              width: double.infinity,
              child: EzText('Home list alignment', textAlign: homeText),
            ),
            SegmentedButton<ListAlignment>(
              segments: alignmentSegments,
              selected: <ListAlignment>{homeAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                await EzConfig.setString(
                  homeAlignmentKey,
                  selected.configValue,
                );
                setState(() {
                  homeAlign = selected;
                  homeAxis = selected.axisValue;
                  homeText = selected.textValue;
                });
              },
            ),
            spacer,

            // Full list align
            SizedBox(
              width: double.infinity,
              child: EzText('Full list alignment', textAlign: fullText),
            ),
            SegmentedButton<ListAlignment>(
              segments: alignmentSegments,
              selected: <ListAlignment>{fullAlign},
              showSelectedIcon: false,
              onSelectionChanged: (Set<ListAlignment>? choice) async {
                if (choice?.first == null) return;
                final ListAlignment selected = choice!.first;

                await EzConfig.setString(
                  fullListAlignmentKey,
                  selected.configValue,
                );
                setState(() {
                  fullAlign = selected;
                  fullAxis = selected.axisValue;
                  fullText = selected.textValue;
                });
              },
            ),
          ],
          resetSpacer: divider,
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
