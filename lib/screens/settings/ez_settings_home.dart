/* sos
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../export.dart';
import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class EzSettingsHomeScreen extends StatefulWidget {
  const EzSettingsHomeScreen({super.key});

  @override
  State<EzSettingsHomeScreen> createState() => _EzSettingsHomeScreenState();
}

class _EzSettingsHomeScreenState extends State<EzSettingsHomeScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSeparator separator = EzSeparator();

  late final Lang l10n = Lang.of(context)!;
  late final EFUILang el10n = ezL10n(context);

  // Set the page title //

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ezWindowNamer(context, el10n.ssPageTitle);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScreen(
        useImageDecoration: false,
        child: Center(
          child: EzScrollView(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Global settings
              const EzDominantHandSwitch(),
              spacer,

              const EzThemeModeSwitch(),
              separator,

              EzElevatedIconButton(
                onPressed: () => context.goNamed(textSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.tsPageTitle,
              ),
              spacer,

              EzElevatedIconButton(
                onPressed: () => context.goNamed(layoutSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.lsPageTitle,
              ),
              spacer,

              const EzElevatedButton(text: 'Design'),
              spacer,

              EzElevatedIconButton(
                onPressed: () => context.goNamed(colorSettingsPath),
                icon: EzIcon(Icons.navigate_next),
                label: el10n.csPageTitle,
              ),
              spacer,

              const EzElevatedButton(text: 'Wallpapers'),
              separator,

              const EzResetButton(),
              separator,
            ],
          ),
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
