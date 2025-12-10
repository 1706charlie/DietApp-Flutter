import 'dart:collection';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ciqual.dart';
import 'security_provider.dart';

final ciqualProvider =
AsyncNotifierProvider<CiqualNotifier, SplayTreeSet<Ciqual>>(() => CiqualNotifier());

class CiqualNotifier extends AsyncNotifier<SplayTreeSet<Ciqual>> {
  @override
  Future<SplayTreeSet<Ciqual>> build() async {
    ref.watch(securityProvider);
    state = AsyncData(SplayTreeSet<Ciqual>());
    state = AsyncLoading();
    try {
      return SplayTreeSet<Ciqual>.from(await Ciqual.getCiqual());
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return SplayTreeSet<Ciqual>();
    }
  }
}
