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
              const EzElevatedButton(text: 'Home time'),
              spacer,
              const EzElevatedButton(text: 'Home date'),
              spacer,
              const EzElevatedButton(text: 'Home weather'),
              spacer,
              const EzElevatedButton(text: 'Weather position'),
              spacer,
              const EzElevatedButton(text: 'Hide status bar'),
              separator,

              // Home list //
              const EzElevatedButton(text: 'Home packages'),
              spacer,
              const EzElevatedButton(text: 'Home alignment'),
              spacer,
              const EzElevatedButton(text: 'Left package'),
              spacer,
              const EzElevatedButton(text: 'Right package'),
              separator,

              // Full list //
              const EzElevatedButton(text: 'Full list alignment'),
              spacer,
              const EzElevatedButton(text: 'Extend tile'),
              spacer,
              const EzElevatedButton(text: 'Auto search'),
              spacer,
              const EzElevatedButton(text: 'Hidden packages'),
              spacer,
              const EzElevatedButton(text: 'Non-zen packages'),
              spacer,
              const EzElevatedButton(text: 'Zen stream'),
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
