/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import '../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class EmpathetechLauncherScaffold extends StatelessWidget {
  /// [AppBar.title] passthrough (via [Text] widget)
  final String title;

  /// Whether to include [SettingsButton] in the [MenuAnchor]
  final bool showSettings;

  /// [Scaffold.body] passthrough
  final Widget body;

  /// [FloatingActionButton]
  final Widget? fab;

  /// Standardized [Scaffold] for all of the EFUI example app's screens
  const EmpathetechLauncherScaffold({
    super.key,
    this.title = appTitle,
    this.showSettings = true,
    required this.body,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    // Gather the theme data //

    final bool isLefty = EzConfig.get(isLeftyKey) ?? false;
    final EFUILang l10n = ezL10n(context);

    final double toolbarHeight = ezToolbarHeight(context, appTitle);

    // Define custom widgets //

    late final Widget options = MenuAnchor(
      builder: (_, MenuController controller, ___) => IconButton(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        tooltip: l10n.gOptions,
        icon: Icon(Icons.more_vert, semanticLabel: l10n.gOptions),
      ),
      menuChildren: <Widget>[
        (showSettings) ? SettingsButton(context) : EFUICredits(context),
        EzFeedbackMenuButton(
          parentContext: context,
          appName: appTitle,
          supportEmail: 'support@empathetech.net',
        ),
      ],
    );

    // Return the build //

    final Widget theBuild = SelectionArea(
      child: Scaffold(
        // AppBar
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, toolbarHeight),
          child: AppBar(
            excludeHeaderSemantics: true,
            toolbarHeight: toolbarHeight,

            // Leading (aka left)
            leading: isLefty ? options : const EzBackAction(),
            leadingWidth: toolbarHeight,

            // Title
            title: Text(title, textAlign: TextAlign.center),
            centerTitle: true,
            titleSpacing: 0,

            // Actions (aka trailing aka right)
            actions: <Widget>[isLefty ? const EzBackAction() : options],
          ),
        ),

        // Body
        body: body,

        // FAB
        floatingActionButton: fab,
        floatingActionButtonLocation: isLefty
            ? FloatingActionButtonLocation.startFloat
            : FloatingActionButtonLocation.endFloat,

        // Prevents the keyboard from pushing the body up
        resizeToAvoidBottomInset: false,
      ),
    );

    return EzSwapScaffold(
      small: theBuild,
      large: theBuild,
      threshold: smallBreakpoint,
    );
  }
}
