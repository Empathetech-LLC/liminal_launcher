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
  final bool homeApp;
  final bool editing;
  final void Function() editCallback;

  const AppTile({
    super.key,
    required this.app,
    required this.homeApp,
    required this.editing,
    required this.editCallback,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Set pointers //
  late final AppInfo app = widget.app;
  late final bool homeApp = widget.homeApp;
  late bool editing = widget.editing;
  late final void Function() editCallback = widget.editCallback;

  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();

  final double iconSize = EzConfig.get(iconSizeKey);
  final double padding = EzConfig.get(paddingKey);

  // Gather the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final bool showIcon = EzConfig.get(showIconKey);
  final LabelType labelType = LabelTypeConfig.fromValue(
    EzConfig.get(labelTypeKey) ?? defaultConfig[labelTypeKey],
  );
  late final bool extend = EzConfig.get(extendTileKey);
  late bool isHidden = provider.isHidden(app.package);

  // Define custom functions //

  Future<void> activateTile() => launchApp(widget.app.package);
  void holdTile() => setState(() => editing = !editing);

  // Define custom Widgets //

  late final Image icon = Image.memory(
    app.icon!,
    semanticLabel: app.label,
    width: iconSize + padding,
    height: iconSize + padding,
  );

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
              if (app.icon != null) ...<Widget>[icon, spacer],

              // Add to home/remove from home
              EzIconButton(
                onPressed: () async {
                  // TODO: The actual work
                  editCallback();
                  setState(() => editing = false);
                },
                icon: Icon(homeApp
                    ? PlatformIcons(context).remove
                    : PlatformIcons(context).add),
              ),
              spacer,

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
              spacer,

              // Delete
              EzIconButton(
                onPressed: () async {
                  final bool deleted = await deleteApp(context, app);
                  if (deleted) {
                    editCallback();
                    setState(() => editing = false);
                  }
                },
                icon: Icon(PlatformIcons(context).delete),
              ),

              // Close
              if (!homeApp) ...<Widget>[
                spacer,
                EzIconButton(
                  onPressed: () => setState(() => editing = !editing),
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
                  child: _TileButton(
                    text: widget.app.label,
                    type: labelType,
                    showIcon: showIcon,
                    icon: icon,
                    onPressed: activateTile,
                    onLongPress: holdTile,
                  ),
                ),
              )
            : _TileButton(
                text: widget.app.label,
                type: labelType,
                showIcon: showIcon,
                icon: icon,
                onPressed: activateTile,
                onLongPress: holdTile,
              );
  }
}

class _TileButton extends StatelessWidget {
  final String text;
  final LabelType type;
  final bool showIcon;
  final Image? icon;
  final void Function()? onPressed;
  final void Function()? onLongPress;

  const _TileButton({
    required this.text,
    required this.type,
    required this.showIcon,
    required this.icon,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (type == LabelType.none) {
      return EzIconButton(
        icon: icon!,
        tooltip: text,
        onPressed: onPressed,
        onLongPress: onLongPress,
      );
    }

    late final String label;

    switch (type) {
      case LabelType.none:
        label = '';
      case LabelType.initials:
        label = text
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();
      case LabelType.full:
        label = text;
      case LabelType.wingding:
        label = text.runes
            .map((int rune) => String.fromCharCode(rune + 69))
            .join(); // TODO: For realz (or remove)
    }

    return showIcon
        ? EzTextIconButton(
            icon: icon!,
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
