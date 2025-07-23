import 'dart:convert';
import 'package:atv_08/favorite_notifier.dart';
import 'package:atv_08/widgets/last_cat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/cat_model.dart';

class HomeSection extends ConsumerStatefulWidget {
  late final String apiKEY;
  late final String apiURL;

  HomeSection({super.key}) {
    apiKEY = dotenv.env['API_KEY']!;
    apiURL =
        'https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=$apiKEY';
  }

  @override
  ConsumerState<HomeSection> createState() => HomeSectionState();
}

class HomeSectionState extends ConsumerState<HomeSection> {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isFavorite = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchCatAndSetState() async {
    final lastCatState = ref.read(lastFetchedCatProvider.notifier);
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(widget.apiURL));
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          final fetchedCat = CatModel.fromJSON(responseData[0]);
          lastCatState.state = fetchedCat;
          isLoading.value = false;
        } else {
          lastCatState.state = null;
        }
      } else {
        lastCatState.state = null;
        print('Falha no carregamento: ${response.statusCode}');
      }
    } catch (e) {
      lastCatState.state = null;
      print('Erro ao buscar gato: $e');
    }
  }

  void handleFavorite(
    FavoriteNotifier notifier,
    BuildContext context,
    CatModel cat,
  ) {
    final isFav = notifier.isFavorite(cat);
    if (isFav) {
      notifier.removeItem(cat);
      isFavorite.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cat.name ?? 'O gato'} removido dos favoritos!'),
        ),
      );
    } else {
      notifier.addItem(cat);
      isFavorite.value = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cat.name ?? 'O gato'} adicionado aos favoritos!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastCat = ref.watch(lastFetchedCatProvider);
    final favoriteNotifier = ref.watch(favoriteListProvider.notifier);
    isFavorite.value = lastCat != null
        ? favoriteNotifier.isFavorite(lastCat)
        : false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Give Me A Cat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: getBody(lastCat, favoriteNotifier),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchCatAndSetState();
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.pets),
      ),
    );
  }

  Widget getBody(CatModel? cat, FavoriteNotifier favoriteNotifier) {
    if (cat == null) {
      return const Center(
        child: Text(
          'Press the button to get a cat!',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      );
    }
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) {
        if (value) {
          Center(
            child: const CircularProgressIndicator(color: Colors.deepPurple),
          );
        }
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: getImage(cat),
                ),
                const SizedBox(height: 20),
                getStack(cat, favoriteNotifier),
                const SizedBox(height: 10),
                Text(
                  'Origem: ${cat.origin ?? 'Não informada'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.deepOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Temperamento: ${cat.temp ?? 'Não informado'}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.deepOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  cat.desc ?? 'Nenhuma descrição disponível para esta raça.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Image getImage(CatModel cat) {
    return Image.network(
      cat.url,
      width: MediaQuery.of(context).size.width * 0.8,
      height: 250,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          width: MediaQuery.of(context).size.width * 0.8,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error_outline, size: 60, color: Colors.grey),
          ),
        );
      },
    );
  }

  Stack getStack(CatModel cat, FavoriteNotifier favoriteNotifier) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            cat.name ?? 'Raça Desconhecida',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          right: 10,
          child: ValueListenableBuilder(
            valueListenable: isFavorite,
            builder: (context, value, child) => IconButton(
              onPressed: () => {handleFavorite(favoriteNotifier, context, cat)},
              icon: Icon(
                isFavorite.value ? Icons.favorite : Icons.favorite_border,
                color: Colors.deepOrange,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
