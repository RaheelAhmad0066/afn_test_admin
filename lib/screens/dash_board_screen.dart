import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/constants/responsive.dart';
import 'package:afn_test_admin/controllers/controller.dart';
import 'package:afn_test_admin/screens/components/dashboard_content.dart';
import 'package:afn_test_admin/screens/blog_post_screen.dart';
import 'package:afn_test_admin/screens/message_screen.dart';
import 'package:afn_test_admin/screens/leaderboard_screen.dart';
import 'components/drawer_menu.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<Controller>()) {
      Get.put(Controller());
    }
    
    final controller = Get.find<Controller>();
    
    return Scaffold(
      backgroundColor: bgColor,
      drawer: DrawerMenu(),
      key: controller.scaffoldKey,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) Expanded(child: DrawerMenu(),),
            Expanded(
              flex: 5,
              child: Obx(() => _buildPageContent(controller.currentIndex.value)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return DashboardContent();
      case 1:
        return BlogPostScreen();
      case 2:
        return MessageScreen();
      case 3:
        return LeaderboardScreen();
      default:
        return DashboardContent();
    }
  }


}