import 'package:atv_08/favorite_notifier.dart';
import 'package:atv_08/models/cat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesSection extends ConsumerStatefulWidget {
  const FavoritesSection({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => FavoriteSectionState();
}

class FavoriteSectionState extends ConsumerState<FavoritesSection> {
  Image getImage(CatModel cat) {
    return Image.network(
      cat.url,
      width: MediaQuery.of(context).size.width * 0.75,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.75,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error_outline, size: 60, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget getCatItemContainer(CatModel cat, FavoriteNotifier notifier) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: getImage(cat),
          ),
          const SizedBox(height: 15),
          Text(
            cat.name ?? 'Raça Desconhecida',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Origem: ${cat.origin ?? 'Não informada'}',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.deepOrange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Temperamento: ${cat.temp ?? 'Não informado'}',
            style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            cat.desc ?? 'Nenhuma descrição disponível para esta raça.',
            style: const TextStyle(fontSize: 15, height: 1.4),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteCats = ref.read(favoriteListProvider);
    final favoritesNotifier = ref.read(favoriteListProvider.notifier);
    final length = favoriteCats.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Cats',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: length == 0
          ? const Center(
              child: Text(
                'No favorite cats yet',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 16.0,
                right: 16.0,
              ),
              itemCount: length,
              itemBuilder: (context, index) {
                final cat = favoriteCats[index];
                return Align(
                  child: getCatItemContainer(cat, favoritesNotifier),
                );
              },
            ),
    );
  }
}
