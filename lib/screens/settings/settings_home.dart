/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../screens/export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSeparator separator = EzSeparator();

  // Define the build data //

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  //* Return the build *//
  // TODO: Should some of these go into custom pre-existing screens?
  // Example: Home alignment in layout settings

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      SafeArea(
        child: EzScreen(
          child: EzScrollView(
            children: <Widget>[
              // Functionality disclaimer
              const EzWarning(
                'Changes will take full effect after a restart.\n\nHave fun!',
              ),
              separator,

              // Top third //
              const EzSwitchPair(text: 'Home time', value: true),
              spacer,
              const EzSwitchPair(text: 'Home date', value: true),
              spacer,
              const EzSwitchPair(text: 'Home weather', value: true),
              spacer,
              const EzSwitchPair(text: 'Weather position', value: true),
              spacer,
              const EzSwitchPair(text: 'Hide status bar', value: true),
              separator,

              // Home list //
              const EzSwitchPair(text: 'Home packages', value: true),
              spacer,
              const EzSwitchPair(text: 'Home alignment', value: true),
              spacer,
              const EzSwitchPair(text: 'Left package', value: true),
              spacer,
              const EzSwitchPair(text: 'Right package', value: true),
              separator,

              // Full list //
              const EzSwitchPair(text: 'Full list alignment', value: true),
              spacer,
              const EzSwitchPair(text: 'Extend tile', value: true),
              spacer,
              const EzSwitchPair(text: 'Auto search', value: true),
              spacer,
              const EzSwitchPair(text: 'Hidden packages', value: true),
              spacer,
              const EzSwitchPair(text: 'Non-zen packages', value: true),
              spacer,
              const EzSwitchPair(text: 'Zen stream', value: true),
              separator,

              // Appearance
              EzElevatedIconButton(
                onPressed: () => context.goNamed(ezSettingsHomePath),
                icon: EzIcon(Icons.navigate_next),
                label: 'Appearance settings',
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
