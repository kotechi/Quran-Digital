class Surah {
  final int number;
  final int sequence;
  final int totalVerses;
  final String arabicName;
  final String longName;
  final String transliterationEn;
  final String transliterationId;
  final String translationEn;
  final String translationId;
  final String revelationAr;
  final String revelationEn;
  final String revelationId;
  final String tafsirId;

  Surah({
    required this.number,
    required this.sequence,
    required this.totalVerses,
    required this.arabicName,
    required this.longName,
    required this.transliterationEn,
    required this.transliterationId,
    required this.translationEn,
    required this.translationId,
    required this.revelationAr,
    required this.revelationEn,
    required this.revelationId,
    required this.tafsirId,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      sequence: json['sequence'] ?? 0,
      totalVerses: json['numberOfVerses'] ?? 0,
      arabicName: json['name']['short'] ?? 'Unknown',
      longName: json['name']['long'] ?? 'Unknown',
      transliterationEn: json['name']['transliteration']['en'] ?? 'Unknown',
      transliterationId: json['name']['transliteration']['id'] ?? 'Unknown',
      translationEn: json['name']['translation']['en'] ?? 'Unknown',
      translationId: json['name']['translation']['id'] ?? 'Unknown',
      revelationAr: json['revelation']['arab'] ?? 'Unknown',
      revelationEn: json['revelation']['en'] ?? 'Unknown',
      revelationId: json['revelation']['id'] ?? 'Unknown',
      tafsirId: json['tafsir']['id'] ?? 'Unknown',
    );
  }
}
