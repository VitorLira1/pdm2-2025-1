class CatModel {
  final String id;
  final String url;
  final String? name;
  final String? origin;
  final String? temp;
  final String? desc;

  CatModel({
    required this.id,
    required this.url,
    required this.name,
    required this.origin,
    required this.temp,
    required this.desc,
  });

  factory CatModel.fromJSON(Map<String, dynamic> json) {
    String? breedName;
    String? breedOrigin;
    String? breedTemperament;
    String? breedDescription;

    if (json['breeds'] != null && (json['breeds'] as List).isNotEmpty) {
      final breedData = (json['breeds'] as List)[0];
      breedName = breedData['name'];
      breedOrigin = breedData['origin'];
      breedTemperament = breedData['temperament'];
      breedDescription = breedData['description'];
    }

    return CatModel(
      id: json['id'],
      url: json['url'],
      name: breedName,
      origin: breedOrigin,
      temp: breedTemperament,
      desc: breedDescription,
    );
  }
}
