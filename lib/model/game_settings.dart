class GameSettings {
  String team1Name;
  String team2Name;
  int roundDuration;
  int totalRounds;  

  GameSettings({
    this.team1Name = "Takım 1",
    this.team2Name = "Takım 2",
    this.roundDuration = 60,
    this.totalRounds = 3,  
  });

  Map<String, dynamic> toJson() => {
    'team1Name': team1Name,
    'team2Name': team2Name,
    'roundDuration': roundDuration,
    'totalRounds': totalRounds,
  };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    team1Name: json['team1Name'] ?? "Takım 1",
    team2Name: json['team2Name'] ?? "Takım 2",
    roundDuration: json['roundDuration'] ?? 60,
    totalRounds: json['totalRounds'] ?? 3,
  );
}