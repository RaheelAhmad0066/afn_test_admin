import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/leaderboard_model.dart';

class LeaderboardController extends GetxController {
  DatabaseReference? _databaseRef;
  
  DatabaseReference? get databaseRef {
    if (_databaseRef == null) {
      try {
        if (Firebase.apps.isNotEmpty) {
          _databaseRef = FirebaseDatabase.instance.ref();
        }
      } catch (e) {
        print('Firebase not initialized: $e');
      }
    }
    return _databaseRef;
  }
  
  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty && _databaseRef != null;
    } catch (e) {
      return false;
    }
  }

  final RxList<LeaderboardModel> leaderboard = <LeaderboardModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  List<LeaderboardModel> get currentLeaderboard {
    return leaderboard;
  }

  List<LeaderboardModel> get topThree {
    final list = currentLeaderboard.take(3).toList();
    if (list.isEmpty) return [];
    if (list.length == 1) return [list[0]];
    if (list.length == 2) return [list[1], list[0]];
    return [list[1], list[0], list[2]];
  }

  Future<void> loadLeaderboard() async {
    // Wait a bit for Firebase to initialize
    if (Firebase.apps.isEmpty) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    if (!isFirebaseAvailable) {
      print('Firebase not available for leaderboard');
      isLoading.value = false;
      return;
    }
    
    try {
      isLoading.value = true;
      
      final ref = databaseRef;
      if (ref == null) {
        print('Database reference is null');
        leaderboard.clear();
        isLoading.value = false;
        return;
      }
      
      print('Loading leaderboard from Firebase...');
      final snapshot = await ref.child('leaderboard').child('allTime').get();
      
      print('Snapshot exists: ${snapshot.exists}');
      
      if (snapshot.exists) {
        final snapshotValue = snapshot.value;
        print('Snapshot value type: ${snapshotValue.runtimeType}');
        
        if (snapshotValue is Map<dynamic, dynamic>) {
          print('Processing ${snapshotValue.length} users...');
          
          leaderboard.value = snapshotValue.entries.map((entry) {
            try {
              final userData = entry.value;
              final userId = entry.key.toString();
              
              print('Processing user: $userId');
              
              // Handle both Map and dynamic types
              Map<String, dynamic> userMap;
              if (userData is Map) {
                userMap = Map<String, dynamic>.from(userData);
              } else {
                userMap = Map<String, dynamic>.from(userData as Map<dynamic, dynamic>);
              }
              
              return LeaderboardModel.fromJson(userMap, userId);
            } catch (e) {
              print('Error processing user ${entry.key}: $e');
              return null;
            }
          }).whereType<LeaderboardModel>().toList();
          
          print('Loaded ${leaderboard.length} users');
          
          // Sort by total points (descending)
          leaderboard.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
          
          print('Leaderboard sorted. Top user: ${leaderboard.isNotEmpty ? leaderboard[0].userName : "None"}');
          
          // RxList automatically notifies Obx
          leaderboard.refresh();
        } else {
          print('Snapshot value is not a Map: ${snapshotValue.runtimeType}');
          leaderboard.clear();
          leaderboard.refresh();
        }
      } else {
        print('Snapshot does not exist');
        leaderboard.clear();
        leaderboard.refresh();
      }
      
    } catch (e, stackTrace) {
      print('Error loading leaderboard: $e');
      print('Stack trace: $stackTrace');
      leaderboard.clear();
      leaderboard.refresh();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadLeaderboard();
  }
}

