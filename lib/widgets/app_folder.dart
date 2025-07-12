/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import './export.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AppFolder extends StatefulWidget {
  final AppInfoProvider provider;
  final int index;
  final String name;
  final List<String> ids;
  final ListAlignment alignment;
  final bool folderIcon;
  final LabelType appLabel;
  final bool appIcon;
  final bool editing;
  final void Function() refresh;

  const AppFolder({
    super.key,
    required this.provider,
    required this.index,
    required this.name,
    required this.ids,
    required this.alignment,
    required this.folderIcon,
    required this.appIcon,
    required this.appLabel,
    required this.editing,
    required this.refresh,
  });

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> {
  // Gather the theme data //

  static const EzSpacer rowSpacer = EzSpacer(vertical: false);

  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets colPadding = EzInsets.col(spacing);
  late final EdgeInsets rowPadding =
      EdgeInsets.symmetric(horizontal: spacing / 2);

  late final ColorScheme colorScheme = Theme.of(context).colorScheme;

  late final EFUILang el10n = ezL10n(context);
  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  late final List<String> folderList = widget.ids;
  late final Set<String> folderSet = folderList.toSet();

  bool open = false;
  late bool editing = widget.editing;
  late int index = widget.index;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  void refresh() {
    widget.refresh();
    setState(() {});
  }

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
                        await widget.provider.renameFolder(name, index: index);

                    if (success) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(name);
                      }
                      refresh();
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

          // Add apps
          EzIconButton(
            icon: Icon(PlatformIcons(context).add),
            onPressed: () => context.goNamed(
              appListPath,
              extra: listData(
                listCheck: (String id) => !folderSet.contains(id),
                onSelected: (String id) =>
                    widget.provider.addToFolder(id, index: index),
                icon: EzTextBackground(EzRow(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('${widget.name}\t'),
                    EzIcon(
                      PlatformIcons(context).add,
                      color: colorScheme.onSurface,
                    ),
                  ],
                )),
                refresh: refresh,
              ),
            ),
          ),
          rowSpacer,

          if (folderList.isNotEmpty) ...<Widget>[
            // Remove apps
            EzIconButton(
              icon: Icon(PlatformIcons(context).remove),
              onPressed: () => context.goNamed(
                appListPath,
                extra: listData(
                  listCheck: (String id) => folderSet.contains(id),
                  onSelected: (String id) =>
                      widget.provider.removeFromFolder(id, index: index),
                  icon: EzTextBackground(EzRow(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('${widget.name}\t'),
                      EzIcon(
                        PlatformIcons(context).remove,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  )),
                  refresh: refresh,
                ),
              ),
            ),
            rowSpacer,

            // Re-order apps
            EzIconButton(
              icon: Icon(PlatformIcons(context).remove),
              onPressed: () => showPlatformDialog(
                context: context,
                builder: (_) => EzAlertDialog(
                  title: Text(
                    'Reorder ${widget.name}',
                    textAlign: TextAlign.center,
                  ),
                  content: ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) async {
                      final bool reordered =
                          await widget.provider.reorderFolderItem(
                        oldIndex: oldIndex + 1, // name offset
                        newIndex: newIndex + 1,
                        folderIndex: widget.index,
                      );
                      if (reordered) refresh();
                    },
                    children: folderList
                        .map((String id) {
                          final AppInfo? app = widget.provider.appMap[id];
                          if (app == null) return null;

                          return Padding(
                            padding: colPadding,
                            child: TileButton(
                              app: app,
                              type: widget.appLabel,
                              showIcon: widget.appIcon,
                            ),
                          );
                        })
                        .whereType<Widget>()
                        .toList(),
                  ),
                ),
              ),
            ),
            rowSpacer,
          ],

          // Delete folder
          EzIconButton(
            icon: Icon(PlatformIcons(context).delete),
            onPressed: () => widget.provider.deleteFolder(folderList.isEmpty
                ? '${widget.name}$folderSplit$emptyTag'
                : <String>[widget.name, ...folderList].join(folderSplit)),
          ),
          rowSpacer,

          // Drag handle
          EzIcon(
            Icons.drag_handle,
            color: colorScheme.outline,
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
                      final AppInfo? app = widget.provider.appMap[id];
                      if (app == null) return null;

                      return Padding(
                        padding: rowPadding,
                        child: AppTile(
                          app: app,
                          onHomeScreen: null,
                          onSelected: (String id) => launchApp(id),
                          editing: editing,
                          refresh: refresh,
                        ),
                      );
                    })
                    .whereType<Widget>()
                    .toList() +
                closeTail,
          )
        : (widget.folderIcon
            ? EzTextIconButton(
                icon: Icon(
                  PlatformIcons(context).folderOpen,
                  size: EzConfig.get(iconSizeKey) + EzConfig.get(paddingKey),
                ),
                label: widget.name,
                onPressed: toggleOpen,
              )
            : EzTextButton(text: widget.name, onPressed: toggleOpen));
  }
}
