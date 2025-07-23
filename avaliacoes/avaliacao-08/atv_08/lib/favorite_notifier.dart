import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atv_08/models/cat_model.dart';

class FavoriteNotifier extends StateNotifier<List<CatModel>> {
  FavoriteNotifier() : super([]);

  void addItem(CatModel item) {
    if (!state.contains(item)) {
      state = [...state, item];
    }
  }

  void removeItem(CatModel item) {
    state = state.where((i) => i.id != item.id).toList();
  }

  bool isFavorite(CatModel item) {
    return state.contains(item);
  }
}

final favoriteListProvider =
    StateNotifierProvider<FavoriteNotifier, List<CatModel>>(
      (ref) => FavoriteNotifier(),
    );
