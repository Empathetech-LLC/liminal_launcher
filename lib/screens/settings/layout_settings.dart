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
  static const EzDivider divider = EzDivider();

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
      const LiminalScreen(EzLayoutSettings(
        beforeLayout: <Widget>[EzDominantHandSwitch()],
        prefixSpacer: spacer,
        postfixSpacer: divider,
        afterLayout: <Widget>[
          // Home align
          _SegmentedAlignmentButton(
            label: 'Home list alignment',
            configKey: homeAlignmentKey,
            segments: alignmentSegments,
          ),
          spacer,

          // Full list align
          _SegmentedAlignmentButton(
            label: 'Full list alignment',
            configKey: listAlignmentKey,
            segments: alignmentSegments,
          ),
        ],
        resetSpacer: divider,
      )),
      fab: EzBackFAB(context),
    );
  }
}

class _SegmentedAlignmentButton extends StatefulWidget {
  final String label;
  final String configKey;
  final List<ButtonSegment<ListAlignment>> segments;

  const _SegmentedAlignmentButton({
    required this.label,
    required this.configKey,
    required this.segments,
  });

  @override
  State<_SegmentedAlignmentButton> createState() =>
      _SegmentedAlignmentButtonState();
}

class _SegmentedAlignmentButtonState extends State<_SegmentedAlignmentButton> {
  late ListAlignment listAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(widget.configKey) ?? EzConfig.getDefault(widget.configKey),
  );
  late TextAlign textAlign = listAlign.textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      SizedBox(
        width: double.infinity,
        child: EzText(widget.label, textAlign: textAlign),
      ),
      SegmentedButton<ListAlignment>(
        segments: widget.segments,
        selected: <ListAlignment>{listAlign},
        showSelectedIcon: false,
        onSelectionChanged: (Set<ListAlignment>? choice) async {
          if (choice?.first == null) return;
          final ListAlignment selected = choice!.first;

          await EzConfig.setString(widget.configKey, selected.configValue);
          setState(() {
            listAlign = selected;
            textAlign = selected.textAlign;
          });
        },
      ),
    ]);
  }
}
