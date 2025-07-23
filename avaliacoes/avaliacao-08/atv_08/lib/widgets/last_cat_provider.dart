import 'package:atv_08/models/cat_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastFetchedCatProvider = StateProvider<CatModel?>((ref) => null);
