/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// App config //

/// Liminal Launcher
const String appTitle = 'Liminal Launcher';

/// [AppInfo] with package 'net.empathetech.liminal'
final AppInfo self = AppInfo(
  label: appTitle,
  package: 'net.empathetech.liminal',
  removable: false,
);

// EzConfig //

// BTS
const String homeIDsKey = 'home_packages';
const String hiddenIDsKey = 'hidden_packages';
const String renamedIDsKey = 'renamed_apps';
const String appSortKey = 'app_sort';
const String appOrderKey = 'app_order';

// Functionality
const String leftAppKey = 'left_app';
const String rightAppKey = 'right_app';
const String autoSearchKey = 'auto_search';
const String authToEditKey = 'auth_to_edit';
const String autoAddToHomeKey = 'auto_add_to_home';

// Layout
// const String headerOrderKey = 'header_order';
const String homeAlignmentKey = 'home_alignment';
const String fullListAlignmentKey = 'full_list_alignment';

// Design
const String homeTimeKey = 'home_time';
const String homeDateKey = 'home_date';
// const String homeWeatherKey = 'home_weather';
const String listIconKey = 'list_icon';
const String listLabelTypeKey = 'list_label_type';
const String folderIconKey = 'folder_icon';
const String folderLabelTypeKey = 'folder_label_type';

// Image

const String useOSKey = 'use_os';

/// [mobileEmpathConfig] with Liminal additions
final Map<String, Object> defaultConfig = <String, Object>{
  ...mobileEmpathConfig,

  // BTS
  homeIDsKey: <String>[],
  hiddenIDsKey: <String>[],
  appSortKey: AppSort.name.configValue,
  appOrderKey: true,
  renamedIDsKey: <String>[],

  // Functionality
  leftAppKey: '',
  rightAppKey: '',
  autoSearchKey: false,
  authToEditKey: false,
  autoAddToHomeKey: false,

  // Layout
  // headerOrderKey: HeaderOrder.timeFirst.configValue,
  homeAlignmentKey: ListAlignment.center.configValue,
  fullListAlignmentKey: ListAlignment.center.configValue,

  // Design
  homeTimeKey: true,
  homeDateKey: true,
  // homeWeatherKey: true,
  listIconKey: true,
  listLabelTypeKey: LabelType.full.configValue,
  folderIconKey: true,
  folderLabelTypeKey: LabelType.none.configValue,

  // Image
  useOSKey: true,
};

// Custom fonts //

/// 'wingding'
const String wingding = 'Wingding';

const Map<String, String> wingdingMap = <String, String>{
  // Lowercase
  'a': '\u{264B}',
  'b': '\u{264C}',
  'c': '\u{264D}',
  'd': '\u{264E}',
  'e': '\u{264F}',
  'f': '\u{2650}',
  'g': '\u{2651}',
  'h': '\u{2652}',
  'i': '\u{2653}',
  'j': '\u{1F670}',
  'k': '\u{1F675}',
  'l': '\u{25CF}',
  'm': '\u{1F53E}',
  'n': '\u{25A0}',
  'o': '\u{25A1}',
  'p': '\u{1F790}',
  'q': '\u{2751}',
  'r': '\u{2752}',
  's': '\u{2B27}',
  't': '\u{29EB}',
  'u': '\u{25C6}',
  'v': '\u{2756}',
  'w': '\u{2B25}',
  'x': '\u{2327}',
  'y': '\u{2BB9}',
  'z': '\u{2318}',

  // Uppercase
  'A': '\u{270C}',
  'B': '\u{1F44C}',
  'C': '\u{1F44D}',
  'D': '\u{1F44E}',
  'E': '\u{261C}',
  'F': '\u{261E}',
  'G': '\u{261D}',
  'H': '\u{261F}',
  'I': '\u{1F590}',
  'J': '\u{263A}',
  'K': '\u{1F610}',
  'L': '\u{2639}',
  'M': '\u{1F4A3}',
  'N': '\u{2620}',
  'O': '\u{1F3F3}',
  'P': '\u{1F3F1}',
  'Q': '\u{2708}',
  'R': '\u{263C}',
  'S': '\u{1F4A7}',
  'T': '\u{2744}',
  'U': '\u{1F546}',
  'V': '\u{271E}',
  'W': '\u{1F548}',
  'X': '\u{2720}',
  'Y': '\u{2721}',
  'Z': '\u{262A}',
};
