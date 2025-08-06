class GameResult {
  final String playerName;
  final String result;
  final String timestamp;

  GameResult({
    required this.playerName,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'result': result,
        'timestamp': timestamp,
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        playerName: json['playerName'],
        result: json['result'],
        timestamp: json['timestamp'],
      );
}
