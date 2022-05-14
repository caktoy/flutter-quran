class Surah {
  int number;
  String arabic;
  String latin;
  String name;
  int totalAyah;
  Map<String, dynamic> ayah;
  Map<String, dynamic> translation;
  Map<String, dynamic> tafsir;

  Surah(
      {required this.number,
      required this.arabic,
      required this.name,
      required this.latin,
      required this.totalAyah,
      required this.ayah,
      required this.translation,
      required this.tafsir});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
        number: int.parse(json['number']),
        arabic: json['name'],
        name: json['translations']['id']['name'],
        latin: json['name_latin'],
        totalAyah: int.parse(json['number_of_ayah']),
        ayah: json['text'],
        translation: json['translations']['id']['text'],
        tafsir: json['tafsir']['id']['kemenag']['text']);
  }
}
