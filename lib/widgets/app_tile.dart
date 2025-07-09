/* liminal_launcher
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

  /// true for home list, null for home folder, false for false
  /// Quantum computing
  final bool? onHomeScreen;

  final bool editing;
  final void Function()? refresh;

  const AppTile({
    super.key,
    required this.app,
    required this.onHomeScreen,
    required this.editing,
    this.refresh,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Gather the theme data //

  static const EzSpacer rowSpacer = EzSpacer(vertical: false);

  final double iconSize = EzConfig.get(iconSizeKey);
  final double padding = EzConfig.get(paddingKey);

  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final bool showIcon = (widget.onHomeScreen == null)
      ? EzConfig.get(folderIconKey) ?? EzConfig.getDefault(folderIconKey)
      : EzConfig.get(homeIconKey) ?? EzConfig.getDefault(homeIconKey);
  late final LabelType labelType = (widget.onHomeScreen == null)
      ? LabelTypeConfig.fromValue(EzConfig.get(folderLabelTypeKey) ??
          EzConfig.getDefault(folderLabelTypeKey))
      : LabelTypeConfig.fromValue(EzConfig.get(listLabelTypeKey) ??
          EzConfig.getDefault(listLabelTypeKey));

  late bool editing = widget.editing;

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
              if (widget.app.icon != null) ...<Widget>[
                GestureDetector(
                  onTap: activateTile,
                  child: Image.memory(
                    widget.app.icon!,
                    semanticLabel: widget.app.name,
                    width: iconSize + padding,
                    height: iconSize + padding,
                  ),
                ),
                rowSpacer,
              ],

              // Rename
              EzIconButton(
                onPressed: () => showPlatformDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      final TextEditingController renameController =
                          TextEditingController();

                      void onConfirm() async {
                        closeKeyboard(dialogContext);

                        final String name = renameController.text.trim();
                        if (validateRename(name) != null) return null;

                        final bool success =
                            await provider.renameApp(name, id: widget.app.id);

                        if (success) {
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(name);
                          }
                          widget.refresh?.call();
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
                          'Rename ${widget.app.name}?',
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
                icon: Icon(PlatformIcons(context).edit),
              ),
              rowSpacer,

              // Add to home
              if (!provider.hiddenSet.contains(widget.app.id) &&
                  !provider.homeSet.contains(widget.app.id)) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    await provider.addHomeApp(widget.app.id);
                    setState(() => editing = false);
                    widget.refresh?.call();
                  },
                  icon: const Icon(Icons.add_to_home_screen),
                ),
                rowSpacer,
              ],

              // Remove from home
              if (widget.onHomeScreen == true) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    await provider.removeHomeApp(widget.app.id);
                    setState(() => editing = false);
                    widget.refresh?.call();
                  },
                  icon: Icon(PlatformIcons(context).remove),
                ),
                rowSpacer,
              ],

              // Show/hide
              EzIconButton(
                onPressed: () async {
                  provider.hiddenSet.contains(widget.app.id)
                      ? await provider.showApp(widget.app.id)
                      : await provider.hideApp(widget.app.id);
                  setState(() => editing = false);
                  widget.refresh?.call();
                },
                icon: Icon(provider.hiddenSet.contains(widget.app.id)
                    ? PlatformIcons(context).eyeSolid
                    : PlatformIcons(context).eyeSlash),
              ),
              rowSpacer,

              // Info
              EzIconButton(
                onPressed: () => openSettings(widget.app.package),
                icon: Icon(PlatformIcons(context).info),
              ),
              rowSpacer,

              // Delete
              if (widget.app.removable) ...<Widget>[
                EzIconButton(
                  onPressed: () async {
                    final bool deleted = await deleteApp(context, widget.app);
                    if (deleted) {
                      await provider.removeDeleted(widget.app.id);
                      setState(() => editing = false);
                      widget.refresh?.call();
                    }
                  },
                  icon: Icon(PlatformIcons(context).delete),
                ),
                rowSpacer,
              ],

              // Close
              EzIconButton(
                onPressed: () => setState(() => editing = false),
                icon: const Icon(Icons.close),
              ),

              // Drag handle
              if (widget.onHomeScreen == true) ...<Widget>[
                rowSpacer,
                EzIcon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ],
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
            semanticLabel: app.name,
            size: iconSize + padding,
          )
        : Image.memory(
            app.icon!,
            semanticLabel: app.name,
            width: iconSize + padding,
            height: iconSize + padding,
          );

    if (type == LabelType.none) {
      return EzIconButton(
        icon: iconImage,
        tooltip: app.name,
        onPressed: onPressed,
        onLongPress: onLongPress,
      );
    }

    late final String label;

    switch (type) {
      case LabelType.none:
        label = '';
        break;
      case LabelType.initials:
        label = app.name
            .split(' ')
            .map((String word) => word.isNotEmpty ? word[0] : '')
            .join()
            .toUpperCase();
        break;
      case LabelType.full:
        label = app.name;
        break;
      case LabelType.wingding:
        label = app.name
            .split('')
            .map((String char) => wingdingMap[char] ?? char)
            .join();
        break;
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
