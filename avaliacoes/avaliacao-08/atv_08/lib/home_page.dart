import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'cat_model.dart';

class HomePage extends StatefulWidget {
  late final apiKEY;
  late final apiURL;

  HomePage({super.key}) {
    apiKEY = dotenv.env['API_KEY'];
    apiURL =
        'https://api.thecatapi.com/v1/images/search?has_breeds=1&api_key=$apiKEY';
  }

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<CatModel?> _currentCatFuture;

  @override
  void initState() {
    super.initState();
    _currentCatFuture = _fetchCat();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Me A Cat'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: FutureBuilder<CatModel?>(
          future: _currentCatFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.deepPurple);
            } else if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data != null) {
              final cat = snapshot.data!;
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
                    Text(
                      cat.name ?? 'Raça Desconhecida',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                      cat.desc ??
                          'Nenhuma descrição disponível para esta raça.',
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
      ),
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
}
