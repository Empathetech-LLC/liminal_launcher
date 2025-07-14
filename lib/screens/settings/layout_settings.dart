/* liminal_launcher
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
  static const EzSeparator separator = EzSeparator();
  static const EzDivider divider = EzDivider();

  late final TextStyle? titleStyle = Theme.of(context).textTheme.titleLarge;

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
      LiminalScreen(EzLayoutSettings(
        beforeLayout: const <Widget>[EzDominantHandSwitch()],
        prefixSpacer: spacer,
        postfixSpacer: divider,
        afterLayout: <Widget>[
          // Home align
          EzText('Home list alignment', style: titleStyle),
          const _AlignmentSelectors(
            home: true,
            segments: alignmentSegments,
          ),
          separator,

          // Full list align
          EzText('Full list alignment', style: titleStyle),
          const _AlignmentSelectors(
            home: false,
            segments: alignmentSegments,
          ),
        ],
        resetSpacer: divider,
      )),
      fab: EzBackFAB(context),
    );
  }
}

class _AlignmentSelectors extends StatefulWidget {
  final bool home;
  final List<ButtonSegment<ListAlignment>> segments;

  const _AlignmentSelectors({
    required this.home,
    required this.segments,
  });

  @override
  State<_AlignmentSelectors> createState() => _AlignmentSelectorsState();
}

class _AlignmentSelectorsState extends State<_AlignmentSelectors> {
  late final String hConfigKey = widget.home ? homeHAlignKey : listHAlignKey;
  late final String vConfigKey = widget.home ? homeVAlignKey : listVAlignKey;

  late ListAlignment hAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(hConfigKey) ?? EzConfig.getDefault(hConfigKey),
  );

  late ListAlignment vAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(vConfigKey) ?? EzConfig.getDefault(vConfigKey),
  );

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          // Horizontal
          SegmentedButton<ListAlignment>(
            segments: widget.segments,
            selected: <ListAlignment>{hAlign},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ListAlignment>? choice) async {
              if (choice?.first == null) return;
              final ListAlignment selected = choice!.first;

              await EzConfig.setString(hConfigKey, selected.configValue);
              setState(() => hAlign = selected);
            },
          ),
          const EzSpacer(),

          // Vertical
          SegmentedButton<ListAlignment>(
            segments: widget.segments,
            direction: Axis.vertical,
            selected: <ListAlignment>{vAlign},
            showSelectedIcon: false,
            onSelectionChanged: (Set<ListAlignment>? choice) async {
              if (choice?.first == null) return;
              final ListAlignment selected = choice!.first;

              await EzConfig.setString(vConfigKey, selected.configValue);
              setState(() => vAlign = selected);
            },
          ),
        ],
      );
}
