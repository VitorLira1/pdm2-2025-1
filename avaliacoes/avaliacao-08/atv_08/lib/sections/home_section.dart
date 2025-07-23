import 'dart:convert';
import 'package:atv_08/favorite_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/cat_model.dart';

class HomeSection extends ConsumerStatefulWidget {
  late final apiKEY;
  late final apiURL;

  HomeSection({super.key}) {
    apiKEY = dotenv.env['API_KEY'];
    apiURL =
        'https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=$apiKEY';
  }

  @override
  ConsumerState<HomeSection> createState() => HomeSectionState();
}

class HomeSectionState extends ConsumerState<HomeSection> {
  Future<CatModel?>? _currentCatFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<CatModel?> _fetchCat() async {
    try {
      final response = await http.get(Uri.parse(widget.apiURL));
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          return CatModel.fromJSON(responseData[0]);
        }
        return null;
      } else {
        throw Exception('Falha no carregamento: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar gato: $e');
      throw Exception('Erro ao carregar o gato: $e');
    }
  }

  void handleFavorite(
    FavoriteNotifier notifier,
    BuildContext context,
    CatModel cat,
  ) {
    final isFav = notifier.isFavorite(cat);
    if (isFav.value) {
      notifier.removeItem(cat);
      isFav.value = false;
    } else {
      notifier.addItem(cat);
      isFav.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteNotifier = ref.watch(favoriteListProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Me A Cat'),
        backgroundColor: Colors.deepPurple,
      ),
      body: getBody(favoriteNotifier),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentCatFuture = _fetchCat();
          });
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.pets),
      ),
    );
  }

  Widget getBody(FavoriteNotifier favoriteNotifier) {
    if (_currentCatFuture == null) {
      return Center(
        child: Text(
          'Press the button to get a cat',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      );
    }
    return Center(
      child: FutureBuilder<CatModel?>(
        future: _currentCatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.deepPurple);
          } else if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            final cat = snapshot.data!;
            ValueNotifier<bool> isFavorite = favoriteNotifier.isFavorite(cat);
            return SingleChildScrollView(
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
                  getStack(cat, favoriteNotifier, isFavorite),
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
            );
          } else {
            return const Text('Pressione o botão para ver um gato!');
          }
        },
      ),
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

  Stack getStack(
    CatModel cat,
    FavoriteNotifier favoriteNotifier,
    ValueNotifier<bool> isFavorite,
  ) {
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
            builder: (context, isFav, _) {
              return IconButton(
                onPressed: () => {
                  handleFavorite(favoriteNotifier, context, cat),
                },
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.deepOrange,
                  size: 30,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
