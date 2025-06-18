/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AddFAB extends FloatingActionButton {
  /// [FloatingActionButton] that will open a modal for adding more home apps
  AddFAB(BuildContext context, void Function()? onPressed, {super.key})
      : super(
          heroTag: 'add_fab',
          onPressed: onPressed,
          tooltip: 'Add another home app',
          child: EzIcon(PlatformIcons(context).add),
        );
}

class SettingsFAB extends FloatingActionButton {
  /// [FloatingActionButton] that will go to the [SettingsHomeScreen]
  SettingsFAB(BuildContext context, void Function()? onPressed, {super.key})
      : super(
          heroTag: 'settings_fab',
          onPressed: onPressed,
          tooltip: ezL10n(context).ssNavHint,
          child: EzIcon(PlatformIcons(context).settings),
        );
}
