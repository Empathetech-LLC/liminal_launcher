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

  // Gather the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late bool isHidden = provider.isHidden(app.package);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return editing
        ? EzScrollView(
            scrollDirection: Axis.horizontal,
            reverseHands: true,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              spacer,

              // Close
              EzIconButton(
                onPressed: () => setState(() => editing = !editing),
                icon: const Icon(Icons.close),
              ),
            ],
          )
        : EzTextButton(
            text: widget.app.label,
            onPressed: () => launchApp(widget.app.package),
            onLongPress: () => setState(() => editing = !editing),
          );
  }
}
