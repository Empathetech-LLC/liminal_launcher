/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SettingsFAB extends FloatingActionButton {
  /// [FloatingActionButton] that goes to the [SettingsHomeScreen]
  SettingsFAB(BuildContext context, {super.key})
      : super(
          heroTag: 'settings_fab',
          child: EzIcon(PlatformIcons(context).settings),
          onPressed: () => context.goNamed(settingsHomePath),
          tooltip: ezL10n(context).ssNavHint,
        );
}
