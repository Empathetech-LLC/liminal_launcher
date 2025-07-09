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
  /// [Container.alignment] passthrough
  final AlignmentGeometry? alignment;

  /// Screen width
  final double width;

  /// Screen height
  final double height;

  /// [Container.clipBehavior] passthrough
  final Clip clipBehavior;

  /// Screen content
  final Widget child;

  /// Modified [EzScreen]
  const LiminalScreen({
    super.key,
    this.alignment,
    this.width = double.infinity,
    this.height = double.infinity,
    this.clipBehavior = Clip.none,
    required this.child,
  });

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
      alignment: alignment,
      padding: screenMargin,
      decoration: (EzConfig.get(useOSKey) == false) ? buildDecoration() : null,
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      child: SafeArea(child: child),
    );
  }
}
