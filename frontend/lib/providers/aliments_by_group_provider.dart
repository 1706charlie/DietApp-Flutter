import 'dart:collection';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/aliment.dart';
import 'my_aliments_provider.dart';

final alimentsByGroupProvider = Provider.family<SplayTreeSet<Aliment>, String>((ref, group) {
  final allAsync = ref.watch(myAlimentsProvider);
  return allAsync.maybeWhen(
    data: (all) => SplayTreeSet.of(
      all.where((a) => (a.groupeAlimentaire ?? 'Divers') == group),
    ),
    orElse: () => SplayTreeSet<Aliment>(),
  );
});