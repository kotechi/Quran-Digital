// File: lib/models/quran.dart
// Gabungkan semua model ke dalam satu file

class Surah {
  final int number;
  final int sequence;
  final int numberOfVerses;
  final SurahName name;
  final Revelation revelation;
  final Tafsir tafsir;

  Surah({
    required this.number,
    required this.sequence,
    required this.numberOfVerses,
    required this.name,
    required this.revelation,
    required this.tafsir,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      sequence: json['sequence'] as int,
      numberOfVerses: json['numberOfVerses'] as int,
      name: SurahName.fromJson(json['name'] as Map<String, dynamic>),
      revelation: Revelation.fromJson(json['revelation'] as Map<String, dynamic>),
      tafsir: Tafsir.fromJson(json['tafsir'] as Map<String, dynamic>),
    );
  }
}

class SurahName {
  final String short;
  final String long;
  final Translation transliteration;
  final Translation translation;

  SurahName({
    required this.short,
    required this.long,
    required this.transliteration,
    required this.translation,
  });

  factory SurahName.fromJson(Map<String, dynamic> json) {
    return SurahName(
      short: json['short'] as String,
      long: json['long'] as String,
      transliteration: Translation.fromJson(json['transliteration'] as Map<String, dynamic>),
      translation: Translation.fromJson(json['translation'] as Map<String, dynamic>),
    );
  }
}

class Translation {
  final String en;
  final String id;

  Translation({
    required this.en,
    required this.id,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      en: json['en'] as String,
      id: json['id'] as String,
    );
  }
}

class Revelation {
  final String arab;
  final String en;
  final String id;

  Revelation({
    required this.arab,
    required this.en,
    required this.id,
  });

  factory Revelation.fromJson(Map<String, dynamic> json) {
    return Revelation(
      arab: json['arab'] as String,
      en: json['en'] as String,
      id: json['id'] as String,
    );
  }
}

class Tafsir {
  final String id;

  Tafsir({
    required this.id,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      id: json['id'] as String,
    );
  }
}