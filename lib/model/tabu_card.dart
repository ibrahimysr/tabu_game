class TabuCard {
  final String id;
  final String word;
  final List<String> forbiddenWords;

  TabuCard({
    required this.id,
    required this.word,
    required this.forbiddenWords,
  });

  factory TabuCard.fromJson(Map<String, dynamic> json) {
    return TabuCard(
      id: json['Id'],
      word: json['Kelime'],
      forbiddenWords: [
        json['Yasak1'],
        json['Yasak2'],
        json['Yasak3'],
        json['Yasak4'],
        json['Yasak5'],
      ],
    );
  }
}