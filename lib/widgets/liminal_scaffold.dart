/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  /// [Container.alignment] passthrough
  final AlignmentGeometry? alignment;

  /// Margin around the screen content
  final EdgeInsetsGeometry? margin;

  /// Whether the [darkDecorationImageKey]/[lightDecorationImageKey] should be used
  final bool useImageDecoration;

  /// [EzConfig] key that will be used to create a [DecorationImage] background for the screen (dark theme)
  final String darkDecorationImageKey;

  /// [EzConfig] key that will be used to create a [DecorationImage] background for the screen (light theme)
  final String lightDecorationImageKey;

  /// Screen width
  final double width;

  /// Screen height
  final double height;

  /// [Container.constraints] passthrough
  final BoxConstraints? constraints;

  /// [Container.transform] passthrough
  final Matrix4? transform;

  /// [Container.transformAlignment] passthrough
  final AlignmentGeometry? transformAlignment;

  /// [Container.clipBehavior] passthrough
  final Clip clipBehavior;

  /// Screen content
  final Widget child;

  /// [EzScreen] with updated background image handling
  const LiminalScreen({
    super.key,
    this.alignment,
    this.margin,
    this.useImageDecoration = true,
    this.darkDecorationImageKey = darkBackgroundImageKey,
    this.lightDecorationImageKey = lightBackgroundImageKey,
    this.width = double.infinity,
    this.height = double.infinity,
    this.constraints,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    late final WallpaperProvider wallpaper =
        Provider.of<WallpaperProvider>(context);

    late final EdgeInsetsGeometry screenMargin =
        margin ?? EdgeInsets.all(EzConfig.get(marginKey));

    Decoration? buildDecoration() {
      if (wallpaper.useOS) {
        return (wallpaper.wallpaper is Uint8List)
            ? BoxDecoration(
                image: DecorationImage(
                    image: Image.memory(wallpaper.wallpaper).image))
            : null;
      }

      final String decorationKey = isDarkTheme(context)
          ? darkDecorationImageKey
          : lightDecorationImageKey;
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
      decoration: buildDecoration(),
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
