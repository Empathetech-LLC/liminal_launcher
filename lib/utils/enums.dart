/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

// Layout settings //

import 'package:flutter/material.dart';

enum HeaderOrder { timeFirst, weatherFirst }

extension HeaderOrderConfig on HeaderOrder {
  String get value {
    switch (this) {
      case HeaderOrder.timeFirst:
        return 'time_first';
      case HeaderOrder.weatherFirst:
        return 'weather_first';
    }
  }

  static HeaderOrder? fromValue(String value) {
    switch (value) {
      case 'time_first':
        return HeaderOrder.timeFirst;
      case 'weather_first':
        return HeaderOrder.weatherFirst;
      default:
        return null;
    }
  }
}

enum ListAlignment { center, start, end }

extension ListAlignmentConfig on ListAlignment {
  String get label {
    switch (this) {
      case ListAlignment.center:
        return 'center';
      case ListAlignment.start:
        return 'start';
      case ListAlignment.end:
        return 'end';
    }
  }

  MainAxisAlignment get value {
    switch (this) {
      case ListAlignment.center:
        return MainAxisAlignment.center;
      case ListAlignment.start:
        return MainAxisAlignment.start;
      case ListAlignment.end:
        return MainAxisAlignment.end;
    }
  }

  static ListAlignment? fromLabel(String value) {
    switch (value) {
      case 'center':
        return ListAlignment.center;
      case 'start':
        return ListAlignment.start;
      case 'end':
        return ListAlignment.end;
      default:
        return null;
    }
  }
}

// Design settings //

enum LabelType { none, initials, full, wingding }

extension LabelTypeConfig on LabelType {
  String get value {
    switch (this) {
      case LabelType.none:
        return 'none';
      case LabelType.initials:
        return 'initials';
      case LabelType.full:
        return 'full';
      case LabelType.wingding:
        return 'wingding';
    }
  }

  static LabelType? fromValue(String value) {
    switch (value) {
      case 'none':
        return LabelType.none;
      case 'initials':
        return LabelType.initials;
      case 'full':
        return LabelType.full;
      case 'wingding':
        return LabelType.wingding;
      default:
        return null;
    }
  }
}
