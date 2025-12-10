import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/app/my_app.dart';
import '/core/tools/params.dart';

void main() async {
  await Params.init();
  runApp(
    ProviderScope(
      // observers: [MyProviderObserver()],
      child: MyApp(),
    ),
  );
}