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
  final AppInfoProvider listener;
  final AppInfoProvider editor;
  final int index;
  final ListAlignment hAlign;
  final LabelType folderLabel;
  final bool folderIcon;
  final LabelType appLabel;
  final bool appIcon;
  final bool editing;
  final void Function() refresh;

  const AppFolder({
    super.key,
    required this.listener,
    required this.editor,
    required this.index,
    required this.hAlign,
    required this.folderLabel,
    required this.folderIcon,
    required this.appLabel,
    required this.appIcon,
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

  late int index = widget.index;
  late List<String> items = widget.listener.homeList[index].split(folderSplit);

  late String name = items[0];
  late final String folderLabel;

  late List<String> appList =
      (items[1] == emptyTag) ? <String>[] : items.sublist(1);
  late Set<String> appSet = appList.toSet();

  bool open = false;
  late bool editing = widget.editing;

  // Define custom functions //

  void toggleOpen() => setState(() => open = !open);

  void refreshFolder() {
    items = widget.listener.homeList[index].split(folderSplit);
    name = items[0];
    appList = (items[1] == emptyTag) ? <String>[] : items.sublist(1);
    appSet = appList.toSet();
    setState(() {});
  }

  void refreshAll() {
    widget.refresh();
    refreshFolder();
  }

  // Define custom Widgets //

  late final List<Widget> closeTail = <Widget>[
    EzSpacer(space: spacing / 2, vertical: false),
    EzIconButton(icon: const Icon(Icons.close), onPressed: toggleOpen),
  ];

  // Init //

  @override
  void initState() {
    super.initState();

    switch (widget.appLabel) {
      case LabelType.none:
        folderLabel = '';

      case LabelType.initials:
        folderLabel = name
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();

      case LabelType.full:
        folderLabel = name;

      case LabelType.wingding:
        folderLabel = name
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
    }
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return EzScrollView(
        scrollDirection: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.hAlign.mainAxis,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                        await widget.editor.renameFolder(name, index);

                    if (success) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(name);
                      }
                      refreshAll();
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
                      "Rename folder '$name'?",
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
            child: Text(name, style: textTheme.bodyLarge),
          ),
          rowSpacer,

          if (appSet.isNotEmpty) ...<Widget>[
            // Re-order apps
            EzIconButton(
              icon: Icon(PlatformIcons(context).edit),
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) => StatefulBuilder(
                  builder: (_, StateSetter modalState) => Expanded(
                    child: ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) async {
                        final bool reordered =
                            await widget.editor.reorderFolderItem(
                          oldIndex: oldIndex + 1, // name offset
                          newIndex: newIndex + 1,
                          folderIndex: widget.index,
                        );
                        if (reordered) {
                          refreshFolder();
                          modalState(() {}); // TODO: More efficienctly?
                        }
                      },
                      children: appList
                          .map((String id) {
                            final AppInfo? app = widget.listener.appMap[id];
                            if (app == null) return null;

                            return Padding(
                              key: ValueKey<String>(id),
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
            ),
            rowSpacer,

            // Remove apps
            EzIconButton(
              icon: Icon(PlatformIcons(context).remove),
              onPressed: () => context.goNamed(
                appListPath,
                extra: listData(
                  listCheck: (String id) => appSet.contains(id),
                  onSelected: (String id) =>
                      widget.editor.removeFromFolder(id, index),
                  refresh: refreshAll,
                  autoRefresh: true,
                  icon: EzTextBackground(EzRow(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('$name\t', style: textTheme.labelLarge),
                      EzIcon(
                        PlatformIcons(context).remove,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  )),
                ),
              ),
            ),
            rowSpacer,
          ],

          // Add apps
          EzIconButton(
            icon: Icon(PlatformIcons(context).add),
            onPressed: () => context.goNamed(
              appListPath,
              extra: listData(
                listCheck: (String id) => !appSet.contains(id),
                onSelected: (String id) async {
                  final int? indexMod =
                      await widget.editor.addToFolder(id, index);

                  if (indexMod != null) index += indexMod;
                },
                refresh: refreshAll,
                autoRefresh: true,
                icon: EzTextBackground(EzRow(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('$name\t', style: textTheme.labelLarge),
                    EzIcon(
                      PlatformIcons(context).add,
                      color: colorScheme.onSurface,
                    ),
                  ],
                )),
              ),
            ),
          ),
          rowSpacer,

          // Delete folder
          EzIconButton(
            icon: Icon(PlatformIcons(context).delete),
            onPressed: () async {
              final bool success = await widget.editor.deleteFolder(
                  appList.isEmpty
                      ? '$name$folderSplit$emptyTag'
                      : <String>[name, ...appList].join(folderSplit));

              if (success) refreshAll();
            },
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
            mainAxisAlignment: widget.hAlign.mainAxis,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: appList
                    .map((String id) {
                      final AppInfo? app = widget.listener.appMap[id];
                      if (app == null) return null;

                      return Padding(
                        padding: rowPadding,
                        child: AppTile(
                          app: app,
                          listener: widget.listener,
                          editor: widget.editor,
                          onHomeScreen: null,
                          labelType: widget.folderLabel,
                          showIcon: widget.folderIcon,
                          onSelected: (String id) => launchApp(id),
                          editing: editing,
                          refresh: refreshAll,
                        ),
                      );
                    })
                    .whereType<Widget>()
                    .toList() +
                closeTail,
          )
        : (widget.appIcon
            ? EzTextIconButton(
                icon: Icon(
                  PlatformIcons(context).folderOpen,
                  size: EzConfig.get(iconSizeKey) + EzConfig.get(paddingKey),
                ),
                label: folderLabel,
                onPressed: toggleOpen,
              )
            : EzTextButton(text: name, onPressed: toggleOpen));
  }
}
