class Doa {
  final String id;
  final String doa;
  final String ayat;
  final String latin;
  final String artinya;

  Doa({required this.id, required this.doa, required this.ayat, required this.latin, required this.artinya});

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: json['id'],
      doa: json['doa'],
      ayat: json['ayat'],
      latin: json['latin'],
      artinya: json['artinya'],
    );
  }
}
