import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/controllers/leaderboard_controller.dart';
import 'package:afn_test_admin/models/leaderboard_model.dart';
import 'package:afn_test_admin/screens/components/custom_appbar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  String _getProfileAssetImage(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('bryan') || lowerName.contains('alex') || 
        lowerName.contains('ricardo') || lowerName.contains('gary') || 
        lowerName.contains('turner') || lowerName.contains('wolf') ||
        lowerName.contains('veum') || lowerName.contains('sanford')) {
      return 'assets/icons/man.png';
    } else if (lowerName.contains('meghan') || lowerName.contains('marsha') || 
               lowerName.contains('juanita') || lowerName.contains('tamara') || 
               lowerName.contains('becky') || lowerName.contains('fisher') ||
               lowerName.contains('cormier') || lowerName.contains('schmidt') || 
               lowerName.contains('bartell') || lowerName.contains('jessica')) {
      return 'assets/icons/girl.png';
    } else {
      return 'assets/icons/businessman.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LeaderboardController>()) {
      Get.put(LeaderboardController());
    }
    final controller = Get.find<LeaderboardController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(appPadding),
        child: Column(
          children: [
            CustomAppbar(),
            SizedBox(height: appPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.refresh(),
                  icon: Icon(Icons.refresh, color: primaryColor),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            SizedBox(height: appPadding),
            Obx(() {
              final controller = Get.find<LeaderboardController>();
              
              if (controller.isLoading.value) {
                return Container(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading leaderboard...',
                          style: TextStyle(
                            color: lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final leaderboard = controller.currentLeaderboard;
              final topThree = controller.topThree;
              final others = leaderboard.length > 3 ? leaderboard.sublist(3) : <LeaderboardModel>[];

                if (leaderboard.isEmpty) {
                  return Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events, size: 64, color: lightTextColor),
                          SizedBox(height: 16),
                          Text(
                            'No rankings yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: lightTextColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Users will appear here after completing tests',
                            style: TextStyle(
                              fontSize: 14,
                              color: lightTextColor.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Top 3 Podium
                    if (topThree.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(appPadding),
                        margin: EdgeInsets.only(bottom: appPadding),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (topThree.length >= 2)
                              Expanded(
                                child: _buildTopThreeCard(
                                  player: topThree[0],
                                  rank: 2,
                                  isSecond: true,
                                ),
                              ),
                            if (topThree.length >= 2) SizedBox(width: 12),
                            if (topThree.isNotEmpty)
                              Expanded(
                                child: _buildTopThreeCard(
                                  player: topThree.length >= 2 ? topThree[1] : topThree[0],
                                  rank: 1,
                                  isFirst: true,
                                ),
                              ),
                            if (topThree.length >= 3) SizedBox(width: 12),
                            if (topThree.length >= 3)
                              Expanded(
                                child: _buildTopThreeCard(
                                  player: topThree[2],
                                  rank: 3,
                                  isThird: true,
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    // Rest of Leaderboard
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(appPadding),
                            child: Text(
                              'All Rankings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: others.length,
                            itemBuilder: (context, index) {
                              final rank = index + 4;
                              return _buildLeaderboardItem(others[index], rank);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreeCard({
    required LeaderboardModel player,
    required int rank,
    bool isFirst = false,
    bool isSecond = false,
    bool isThird = false,
  }) {
    Color badgeColor = isFirst
        ? primaryColor
        : primaryColor.withOpacity(0.2);
    
    final profileImage = _getProfileAssetImage(player.userName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 90,
              height: isFirst ? 130 : 100,
              decoration: BoxDecoration(
                border: Border.all(color: badgeColor, width: 4),
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: player.userAvatar != null
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(player.userAvatar!),
                        )
                      : Image.asset(
                          profileImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 40);
                          },
                        ),
                ),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            if (isSecond)
              Positioned(
                top: -8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.emoji_events, color: grey, size: 24),
                ),
              ),
            if (isThird)
              Positioned(
                top: -8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.workspace_premium, color: orange, size: 24),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          player.userName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          '${player.totalPoints} pts',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardModel player, int rank) {
    final profileImage = _getProfileAssetImage(player.userName);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: appPadding, vertical: 4),
      padding: EdgeInsets.all(appPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: player.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      player.userAvatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          profileImage,
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person);
                          },
                        );
                      },
                    ),
                  )
                : Image.asset(
                    profileImage,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person);
                    },
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (player.matchesWon > 0)
                  Text(
                    '${player.matchesWon} wins',
                    style: TextStyle(
                      fontSize: 11,
                      color: lightTextColor,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.totalPoints} pts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              Text(
                '${player.testsCompleted} tests',
                style: TextStyle(
                  fontSize: 11,
                  color: lightTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

