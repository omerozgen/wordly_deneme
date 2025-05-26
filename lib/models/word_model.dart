class Word {
  final int id;
  final String ingilizce;
  final String turkce;
  final String ornekCumle;
  final String seviye;

  Word({
    required this.id,
    required this.ingilizce,
    required this.turkce,
    required this.ornekCumle,
    required this.seviye,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      ingilizce: json['ingilizce'],
      turkce: json['turkce'],
      ornekCumle: json['ornek_cumle'],
      seviye: json['seviye'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingilizce': ingilizce,
      'turkce': turkce,
      'ornek_cumle': ornekCumle,
      'seviye': seviye,
    };
  }
}
