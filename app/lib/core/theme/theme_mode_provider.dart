import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light ↔ dark override. Defaults to system; the toggle pins explicit.
final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);
