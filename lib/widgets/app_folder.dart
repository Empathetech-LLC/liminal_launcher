/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppFolder extends StatefulWidget {
  final List<String> packages;
  final AppInfoProvider provider;
  final ListAlignment alignment;
  final bool showIcon;
  final bool editing;
  final void Function()? refreshHome;

  const AppFolder({
    super.key,
    required this.packages,
    required this.provider,
    required this.alignment,
    required this.showIcon,
    required this.editing,
    required this.refreshHome,
  });

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> {
  // Define the build data //

  static const EzSpacer rowSpacer = EzSpacer(vertical: false);

  final EdgeInsets rowPadding = EzInsets.row(EzConfig.get(spacingKey));

  bool open = false;
  late bool editing = widget.editing;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  // Return the build //

  late final List<Widget> closeTail = <Widget>[
    rowSpacer,
    EzIconButton(
      icon: const Icon(Icons.close),
      onPressed: toggleOpen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return open
          ? EzScrollView(
              scrollDirection: Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.alignment.mainAxis,
              children: widget.packages
                      .map((String package) {
                        final AppInfo? app =
                            widget.provider.getAppFromID(package);
                        if (app == null) return null;

                        Padding(
                          padding: rowPadding,
                          child: AppTile(
                            app: app,
                            onHomeScreen: true,
                            editing: editing,
                            refreshHome: widget.refreshHome,
                          ),
                        );
                      })
                      .whereType<Widget>()
                      .toList() +
                  closeTail,
            )
          : (widget.showIcon
              ? EzTextIconButton(
                  icon: EzIcon(PlatformIcons(context).folder),
                  label: 'Folder',
                  onPressed: toggleOpen,
                )
              : EzTextButton(text: 'Folder', onPressed: toggleOpen));
    }

    return open
        ? EzScrollView(
            scrollDirection: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.alignment.mainAxis,
            children: widget.packages
                    .map((String package) {
                      final AppInfo? app =
                          widget.provider.getAppFromID(package);
                      if (app == null) return null;

                      Padding(
                        padding: rowPadding,
                        child: AppTile(
                          app: app,
                          onHomeScreen: true,
                          editing: editing,
                          refreshHome: widget.refreshHome,
                        ),
                      );
                    })
                    .whereType<Widget>()
                    .toList() +
                closeTail,
          )
        : (widget.showIcon
            ? EzTextIconButton(
                icon: EzIcon(PlatformIcons(context).folder),
                label: 'Folder',
                onPressed: toggleOpen,
              )
            : EzTextButton(text: 'Folder', onPressed: toggleOpen));
  }
}
