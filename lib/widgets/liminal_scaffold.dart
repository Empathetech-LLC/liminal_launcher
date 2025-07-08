/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:efui_bios/efui_bios.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LiminalScaffold extends StatelessWidget {
  /// [Scaffold.body] passthrough
  final Widget body;

  /// [FloatingActionButton]
  final Widget? fab;

  /// Standardized [Scaffold] for all of the EFUI example app's screens
  const LiminalScaffold(this.body, {super.key, this.fab});

  @override
  Widget build(BuildContext context) => EzAdaptiveScaffold(
        small: Scaffold(
          body: SafeArea(child: body),
          floatingActionButton: fab,
          floatingActionButtonLocation: EzConfig.get(isLeftyKey) ?? false
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
          resizeToAvoidBottomInset: false,
        ),
      );
}

class LiminalScreen extends StatelessWidget {
  final Widget child;

  /// EzScreen with a pinch detector for [Feedback]
  const LiminalScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) => EzScreen(
        child: GestureDetector(
          onScaleUpdate: (ScaleUpdateDetails details) {
            if (details.scale < 1.0) {
              ezFeedback(
                parentContext: context,
                l10n: ezL10n(context),
                supportEmail: empathSupport,
                appName: 'Liminal',
              );
            }
          },
          child: child,
        ),
      );
}
