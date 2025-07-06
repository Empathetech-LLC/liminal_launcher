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
  final LabelType labelType;
  final bool editing;
  final void Function()? refreshHome;

  const AppFolder({
    super.key,
    required this.packages,
    required this.provider,
    required this.alignment,
    required this.showIcon,
    required this.labelType,
    required this.editing,
    required this.refreshHome,
  });

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> {
  // Gather the theme data //

  static const EzSpacer rowSpacer = EzSpacer(vertical: false);

  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets rowPadding = EzInsets.row(spacing);
  late final EdgeInsets modalPadding = EzInsets.col(spacing);

  late final EFUILang el10n = ezL10n(context);
  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  bool open = false;
  late bool editing = widget.editing;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  // Define custom Widgets //

  late final List<Widget> closeTail = <Widget>[
    rowSpacer,
    EzIconButton(
      icon: const Icon(Icons.close),
      onPressed: toggleOpen,
    ),
  ];

  // Return the build //

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return EzScrollView(
        scrollDirection: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.alignment.mainAxis,
        children: <Widget>[
          // Name
          GestureDetector(
            onTap: () => showPlatformDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  final TextEditingController renameController =
                      TextEditingController();

                  void onConfirm() async {
                    closeKeyboard(dialogContext);

                    final String name = renameController.text.trim();
                    if (validateAppName(name) != null) return null;

                    final bool success = await widget.provider
                        .renameFolder(widget.packages.join(':'), name);

                    if (success) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(name);
                      }
                      widget.refreshHome?.call();
                    }
                  }

                  void onDeny() {
                    closeKeyboard(dialogContext);
                    Navigator.of(dialogContext).pop();
                  }

                  late final List<Widget> materialActions;
                  late final List<Widget> cupertinoActions;

                  (materialActions, cupertinoActions) = ezActionPairs(
                    context: context,
                    confirmMsg: el10n.gApply,
                    onConfirm: onConfirm,
                    confirmIsDestructive: true,
                    denyMsg: el10n.gCancel,
                    onDeny: onDeny,
                  );

                  return EzAlertDialog(
                    title: Text(
                      "Rename folder '${widget.packages[0]}'?",
                      textAlign: TextAlign.center,
                    ),
                    content: Form(
                      child: TextFormField(
                        controller: renameController,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        autofillHints: const <String>[AutofillHints.name],
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: validateAppName,
                      ),
                    ),
                    materialActions: materialActions,
                    cupertinoActions: cupertinoActions,
                    needsClose: false,
                  );
                }),
            child: Text(widget.packages[0], style: textTheme.bodyLarge),
          ),
          rowSpacer,

          // Edit apps
          EzIconButton(
            icon: Icon(PlatformIcons(context).edit),
            onPressed: () => showModalBottomSheet(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (_) => StatefulBuilder(
                builder: (_, StateSetter setModalState) {
                  final Set<String> inFolder =
                      widget.packages.sublist(1).toSet();

                  void onRemove(String package) async {
                    final bool removed = await widget.provider.removeFromFolder(
                      fullName: widget.packages.join(':'),
                      package: package,
                    );

                    if (removed) {
                      setModalState(() => inFolder.remove(package));
                    }
                  }

                  void onAdd(String package) async {
                    final bool added = await widget.provider.addToFolder(
                      fullName: widget.packages.join(':'),
                      package: package,
                    );

                    if (added) {
                      setModalState(() => inFolder.add(package));
                    }
                  }

                  return EzScrollView(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: widget.alignment.crossAxis,
                    children: <Widget>[
                      // Remove
                      ...widget.packages.sublist(1).map((String package) {
                        final AppInfo? app =
                            widget.provider.getAppFromID(package);
                        if (app == null) return null;

                        return Padding(
                            key: ValueKey<String>(app.keyLabel),
                            padding: modalPadding,
                            child: TileButton(
                              app: app,
                              type: widget.labelType,
                              showIcon: widget.showIcon,
                              onPressed: () => onRemove(app.package),
                            ));
                      }).whereType<Widget>(),
                      EzDivider(height: spacing),

                      // Add
                      ...widget.provider.apps
                          .where((AppInfo app) =>
                              !inFolder.contains(app.package) &&
                              !widget.provider.hiddenPS.contains(app.package))
                          .map((AppInfo app) {
                        return Padding(
                          key: ValueKey<String>(app.keyLabel),
                          padding: modalPadding,
                          child: TileButton(
                            app: app,
                            type: widget.labelType,
                            showIcon: widget.showIcon,
                            onPressed: () => onAdd(app.package),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          rowSpacer,

          // Delete folder
          EzIconButton(
            icon: Icon(PlatformIcons(context).delete),
            onPressed: () =>
                widget.provider.deleteFolder(widget.packages.join(':')),
          ),
          rowSpacer,

          // Drag handle
          EzIcon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.outline,
          ),
        ],
      );
    }

    return open
        ? EzScrollView(
            scrollDirection: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.alignment.mainAxis,
            children: widget.packages
                    .sublist(1)
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
                label: widget.packages[0],
                onPressed: toggleOpen,
              )
            : EzTextButton(text: widget.packages[0], onPressed: toggleOpen));
  }
}
