/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import './export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppFolder extends StatefulWidget {
  final int index;
  final String name;
  final List<String> ids;
  final ListAlignment alignment;
  final bool showIcon;
  final LabelType labelType;
  final bool editing;
  final void Function()? refreshHome;

  const AppFolder({
    super.key,
    required this.index,
    required this.name,
    required this.ids,
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

  late final EdgeInsets rowPadding =
      EdgeInsets.symmetric(horizontal: spacing / 2);
  late final EdgeInsets modalPadding = EzInsets.col(spacing);

  late final EFUILang el10n = ezL10n(context);
  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final List<String> folderList = widget.ids;
  late final Set<String> folderSet = folderList.toSet();

  bool open = false;
  late bool editing = widget.editing;
  late int index = widget.index;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  // Define custom Widgets //

  late final List<Widget> closeTail = <Widget>[
    EzSpacer(space: spacing / 2, vertical: false),
    EzIconButton(icon: const Icon(Icons.close), onPressed: toggleOpen),
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
                    if (validateRename(name) != null) return null;

                    final bool success =
                        await provider.renameFolder(name, index: index);

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
                      "Rename folder '${widget.name}'?",
                      textAlign: TextAlign.center,
                    ),
                    content: Form(
                      child: TextFormField(
                        controller: renameController,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        autofillHints: const <String>[AutofillHints.name],
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: validateRename,
                      ),
                    ),
                    materialActions: materialActions,
                    cupertinoActions: cupertinoActions,
                    needsClose: false,
                  );
                }),
            child: Text(widget.name, style: textTheme.bodyLarge),
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
                  void onRemove(String id) async {
                    final bool removed =
                        await provider.removeFromFolder(id, index: index);

                    if (removed) {
                      folderList.remove(id);
                      folderSet.remove(id);

                      widget.refreshHome?.call();
                      setState(() {});
                      setModalState(() {});
                    }
                  }

                  void onAdd(String id) async {
                    final int? indexMod =
                        await provider.addToFolder(id, index: index);

                    if (indexMod != null) {
                      folderList.add(id);
                      folderSet.add(id);

                      widget.refreshHome?.call();
                      setState(() => index += indexMod);
                      setModalState(() {});
                    }
                  }

                  return EzScrollView(
                    key: ValueKey<int>(folderSet.length),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: widget.alignment.crossAxis,
                    children: <Widget>[
                      // Remove
                      ...folderList.map((String id) {
                        final AppInfo? app = provider.appMap[id];
                        if (app == null) return null;

                        return Padding(
                            key: ValueKey<String>(app.id),
                            padding: modalPadding,
                            child: TileButton(
                              app: app,
                              type: widget.labelType,
                              showIcon: widget.showIcon,
                              onPressed: () => onRemove(app.id),
                            ));
                      }).whereType<Widget>(),
                      EzDivider(height: spacing),

                      // Add
                      ...provider.apps
                          .where((AppInfo app) =>
                              !folderSet.contains(app.id) &&
                              !provider.hiddenSet.contains(app.id))
                          .map((AppInfo app) {
                        return Padding(
                          key: ValueKey<String>(app.id),
                          padding: modalPadding,
                          child: TileButton(
                            app: app,
                            type: widget.labelType,
                            showIcon: widget.showIcon,
                            onPressed: () => onAdd(app.id),
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
            onPressed: () => provider.deleteFolder(
                <String>[widget.name, ...folderList].join(folderSplit)),
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
            children: folderList
                    .map((String id) {
                      final AppInfo? app = provider.appMap[id];
                      if (app == null) return null;

                      return Padding(
                        padding: rowPadding,
                        child: AppTile(
                          app: app,
                          onHomeScreen: null,
                          editing: editing,
                          refresh: widget.refreshHome,
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
                label: widget.name,
                onPressed: toggleOpen,
              )
            : EzTextButton(text: widget.name, onPressed: toggleOpen));
  }
}
