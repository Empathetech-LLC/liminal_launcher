/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppTile extends StatefulWidget {
  final AppInfo app;
  final bool onHomeScreen;
  final bool editing;
  final void Function()? stateSetter;

  const AppTile({
    super.key,
    required this.app,
    required this.onHomeScreen,
    required this.editing,
    this.stateSetter,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();

  final double iconSize = EzConfig.get(iconSizeKey);
  final double padding = EzConfig.get(paddingKey);

  // Gather the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);
  late final AppInfo app = widget.app;
  late bool isHidden = provider.isHidden(app.package);

  final bool showIcon =
      EzConfig.get(showIconKey) ?? EzConfig.getDefault(showIconKey);
  final LabelType labelType = LabelTypeConfig.fromValue(
    EzConfig.get(labelTypeKey) ?? EzConfig.getDefault(labelTypeKey),
  );
  late final bool extend = EzConfig.get(extendTileKey);

  late final bool onHomeScreen = widget.onHomeScreen;
  late bool editing = widget.editing;
  late final void Function()? stateSetter = widget.stateSetter;

  late final List<String> homePackages =
      EzConfig.get(homePackagesKey) ?? EzConfig.getDefault(homePackagesKey);

  // Define custom functions //

  Future<void> activateTile() => launchApp(widget.app.package);
  void holdTile() => setState(() => editing = !editing);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return editing
        ? EzScrollView(
            scrollDirection: Axis.horizontal,
            reverseHands: true,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // App icon
              if (app.icon != null) ...<Widget>[
                GestureDetector(
                  onTap: activateTile,
                  child: Image.memory(
                    app.icon!,
                    semanticLabel: app.label,
                    width: iconSize + padding,
                    height: iconSize + padding,
                  ),
                ),
                spacer,
              ],

              // Add to home/remove from home
              if (!isHidden) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    if (onHomeScreen) {
                      homePackages.remove(app.package);
                      await EzConfig.setStringList(
                        homePackagesKey,
                        homePackages,
                      );

                      setState(() => editing = false);
                      stateSetter?.call();
                    } else {
                      homePackages.add(app.package);
                      await EzConfig.setStringList(
                        homePackagesKey,
                        homePackages,
                      );

                      setState(() => editing = false);
                    }
                  },
                  icon: Icon(onHomeScreen
                      ? PlatformIcons(context).remove
                      : Icons.add_to_home_screen),
                ),
                spacer,
              ],

              // Show/hide
              EzIconButton(
                onPressed: () async {
                  late final bool success;

                  success = (isHidden)
                      ? await showApp(app.package)
                      : await hideApp(app.package);

                  if (success) setState(() => isHidden = !isHidden);
                },
                icon: Icon(isHidden
                    ? PlatformIcons(context).eyeSolid
                    : PlatformIcons(context).eyeSlash),
              ),
              spacer,

              // Info
              EzIconButton(
                onPressed: () => openSettings(app.package),
                icon: Icon(PlatformIcons(context).info),
              ),

              // Delete

              if (app.removable) ...<Widget>[
                spacer,
                EzIconButton(
                  onPressed: () async {
                    final bool deleted = await deleteApp(context, app);
                    if (deleted) {
                      setState(() => editing = false);
                      stateSetter?.call();
                    }
                  },
                  icon: Icon(PlatformIcons(context).delete),
                ),
              ],

              // Close
              if (!onHomeScreen) ...<Widget>[
                spacer,
                EzIconButton(
                  onPressed: () => setState(() => editing = false),
                  icon: const Icon(Icons.close),
                ),
              ]
            ],
          )
        : extend
            ? SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: activateTile,
                  onLongPress: holdTile,
                  child: TileButton(
                    app: widget.app,
                    type: labelType,
                    showIcon: showIcon,
                    onPressed: activateTile,
                    onLongPress: holdTile,
                  ),
                ),
              )
            : TileButton(
                app: widget.app,
                type: labelType,
                showIcon: showIcon,
                onPressed: activateTile,
                onLongPress: holdTile,
              );
  }
}

class TileButton extends StatelessWidget {
  final AppInfo app;
  final LabelType type;
  final bool showIcon;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const TileButton({
    super.key,
    required this.app,
    required this.type,
    required this.showIcon,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    late final double iconSize = EzConfig.get(iconSizeKey);
    late final double padding = EzConfig.get(paddingKey);

    late final Widget iconImage = (app.icon == null)
        ? Icon(
            Icons.question_mark,
            semanticLabel: app.label,
            size: iconSize + padding,
          )
        : Image.memory(
            app.icon!,
            semanticLabel: app.label,
            width: iconSize + padding,
            height: iconSize + padding,
          );

    if (type == LabelType.none) {
      return EzIconButton(
        icon: iconImage,
        tooltip: app.label,
        onPressed: onPressed,
        onLongPress: onLongPress,
      );
    }

    late final String label;

    switch (type) {
      case LabelType.none:
        label = '';
      case LabelType.initials:
        label = app.label
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();
      case LabelType.full:
        label = app.label;
      case LabelType.wingding:
        label = app.label.runes
            .map((int rune) => String.fromCharCode(rune + 69))
            .join(); // TODO: For realz (or remove)
    }

    return showIcon
        ? EzTextIconButton(
            icon: iconImage,
            label: label,
            onPressed: onPressed,
            onLongPress: onLongPress,
          )
        : EzTextButton(
            text: label,
            onPressed: onPressed,
            onLongPress: onLongPress,
          );
  }
}
