import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atv_08/models/cat_model.dart';

class FavoriteNotifier extends StateNotifier<List<CatModel>> {
  FavoriteNotifier() : super([]);

  ValueNotifier<bool> isFav = ValueNotifier(false);

  void addItem(CatModel item) {
    if (!state.contains(item)) {
      state = [...state, item];
    }
  }

  void removeItem(CatModel item) {
    state = state.where((i) => i.id != item.id).toList();
  }

  ValueNotifier<bool> isFavorite(CatModel item) {
    isFav.value = state.contains(item);
    return isFav;
  }
}

final favoriteListProvider =
    StateNotifierProvider<FavoriteNotifier, List<CatModel>>(
      (ref) => FavoriteNotifier(),
    );
