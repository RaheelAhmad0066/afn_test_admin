import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../models/analytic_info_model.dart';
import '../constants/constants.dart';

class DashboardController extends GetxController {
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

  // Analytics Data
  final RxList<AnalyticInfo> analytics = <AnalyticInfo>[
    AnalyticInfo(
      title: "Total Users",
      count: 0,
      svgSrc: "assets/icons/Subscribers.svg",
      color: primaryColor,
    ),
    AnalyticInfo(
      title: "Total Topics",
      count: 0,
      svgSrc: "assets/icons/Post.svg",
      color: purple,
    ),
    AnalyticInfo(
      title: "Total Tests",
      count: 0,
      svgSrc: "assets/icons/Pages.svg",
      color: orange,
    ),
    AnalyticInfo(
      title: "Total Questions",
      count: 0,
      svgSrc: "assets/icons/Comments.svg",
      color: green,
    ),
  ].obs;

  // Loading States
  final RxBool isLoading = false.obs;

  // Chart Data - Users by day (last 7 days)
  final RxList<Map<String, dynamic>> usersChartData = <Map<String, dynamic>>[
    {'day': 'Mon', 'users': 5},
    {'day': 'Tue', 'users': 8},
    {'day': 'Wed', 'users': 12},
    {'day': 'Thu', 'users': 6},
    {'day': 'Fri', 'users': 15},
    {'day': 'Sat', 'users': 10},
    {'day': 'Sun', 'users': 7},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load all dashboard data from Firebase
  Future<void> loadDashboardData() async {
    // Wait a bit for Firebase to initialize
    if (Firebase.apps.isEmpty) {
      // Try to wait for Firebase initialization
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    if (!isFirebaseAvailable) {
      print('Firebase not available - Dashboard will show default values');
      // Keep default values (0) if Firebase not available
      return;
    }

    try {
      isLoading.value = true;
      
      // Load all data in parallel
      await Future.wait([
        loadUsersCount(),
        loadTopicsCount(),
        loadTestsCount(),
        loadQuestionsCount(),
        loadUsersChartData(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load total users count
  Future<void> loadUsersCount() async {
    if (!isFirebaseAvailable) return;
    
    try {
      final snapshot = await databaseRef!.child('users').get();
      int count = 0;
      
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          count = data.length;
        }
      }
      
      // Update analytics[0] - Total Users
      if (analytics.isNotEmpty) {
        analytics[0] = analytics[0].copyWith(count: count);
        analytics.refresh();
        update(); // Notify GetBuilder
      }
    } catch (e) {
      print('Error loading users count: $e');
    }
  }

  /// Load total topics count
  Future<void> loadTopicsCount() async {
    if (!isFirebaseAvailable) return;
    
    try {
      final snapshot = await databaseRef!.child('topics').get();
      int count = 0;
      
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          count = data.length;
        }
      }
      
      // Update analytics[1] - Total Topics
      if (analytics.length > 1) {
        analytics[1] = analytics[1].copyWith(count: count);
        analytics.refresh();
        update(); // Notify GetBuilder
      }
    } catch (e) {
      print('Error loading topics count: $e');
    }
  }

  /// Load total tests count
  Future<void> loadTestsCount() async {
    if (!isFirebaseAvailable) return;
    
    try {
      final snapshot = await databaseRef!.child('tests').get();
      int count = 0;
      
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          count = data.length;
        }
      }
      
      // Update analytics[2] - Total Tests
      if (analytics.length > 2) {
        analytics[2] = analytics[2].copyWith(count: count);
        analytics.refresh();
        update(); // Notify GetBuilder
      }
    } catch (e) {
      print('Error loading tests count: $e');
    }
  }

  /// Load total questions count
  Future<void> loadQuestionsCount() async {
    if (!isFirebaseAvailable) return;
    
    try {
      final snapshot = await databaseRef!.child('questions').get();
      int count = 0;
      
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          count = data.length;
        }
      }
      
      // Update analytics[3] - Total Questions
      if (analytics.length > 3) {
        analytics[3] = analytics[3].copyWith(count: count);
        analytics.refresh();
        update(); // Notify GetBuilder
      }
    } catch (e) {
      print('Error loading questions count: $e');
    }
  }

  /// Load users chart data (last 7 days)
  Future<void> loadUsersChartData() async {
    if (!isFirebaseAvailable) return;
    
    try {
      final snapshot = await databaseRef!.child('users').get();
      
      if (!snapshot.exists) {
        usersChartData.clear();
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        usersChartData.clear();
        return;
      }

      // Get last 7 days
      final now = DateTime.now();
      final last7Days = List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        return DateTime(date.year, date.month, date.day);
      });

      // Count users by registration date
      final Map<DateTime, int> usersByDate = {};
      
      for (var entry in data.entries) {
        final userData = entry.value;
        if (userData is Map) {
          // Try to get registration date
          final timestamp = userData['lastUpdated'] ?? userData['createdAt'];
          if (timestamp != null) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              timestamp is int ? timestamp : int.tryParse(timestamp.toString()) ?? 0
            );
            final dayStart = DateTime(date.year, date.month, date.day);
            
            if (last7Days.contains(dayStart)) {
              usersByDate[dayStart] = (usersByDate[dayStart] ?? 0) + 1;
            }
          }
        }
      }

      // Create chart data
      usersChartData.value = last7Days.map((date) {
        final dayName = _getDayName(date.weekday);
        final count = usersByDate[date] ?? 0;
        return {
          'day': dayName,
          'users': count,
        };
      }).toList();
      
      usersChartData.refresh();
      update(); // Notify GetBuilder (if used)
    } catch (e) {
      print('Error loading users chart data: $e');
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Day';
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboardData();
  }
}

