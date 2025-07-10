/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

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
          body: body,
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

  const LiminalScreen(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry screenMargin =
        EdgeInsets.all(EzConfig.get(marginKey));

    Decoration? buildDecoration() {
      final String decorationKey = isDarkTheme(context)
          ? darkBackgroundImageKey
          : lightBackgroundImageKey;
      final String? imagePath = EzConfig.get(decorationKey);

      if (imagePath == null || imagePath == noImageValue) {
        return null;
      } else {
        final BoxFit? fit =
            ezFitFromName(EzConfig.get('$decorationKey$boxFitSuffix'));

        return BoxDecoration(
          image: DecorationImage(image: ezImageProvider(imagePath), fit: fit),
        );
      }
    }

    return Container(
      padding: screenMargin,
      decoration: (EzConfig.get(useOSKey) == false) ? buildDecoration() : null,
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.none,
      child: SafeArea(child: child),
    );
  }
}
