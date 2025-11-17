/// Leaderboard Model
class LeaderboardModel {
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final int totalPoints;
  final int testsCompleted;
  final int matchesWon;
  final DateTime lastUpdated;

  LeaderboardModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.totalPoints,
    required this.testsCompleted,
    this.matchesWon = 0,
    required this.lastUpdated,
  });

  factory LeaderboardModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return LeaderboardModel(
      userId: id,
      userName: json['userName']?.toString() ?? 'Unknown User',
      userEmail: json['userEmail']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString(),
      totalPoints: (json['totalPoints'] ?? 0) as int,
      testsCompleted: (json['testsCompleted'] ?? 0) as int,
      matchesWon: (json['matchesWon'] ?? 0) as int,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int)
          : DateTime.now(),
    );
  }
}

