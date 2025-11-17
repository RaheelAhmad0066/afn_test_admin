import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/controllers/controller.dart';
import 'package:afn_test_admin/screens/components/drawer_list_tile.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();
    
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(appPadding),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
            ),
            child: Column(
              children: [
                // Logo Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu_book,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // App Name
                Center(
                  child: Text(
                    'Quizzex',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          DrawerListTile(
            title: 'Dash Board',
            svgSrc: 'assets/icons/Dashboard.svg',
            index: 0,
            tap: () {
              controller.changePage(0);
            },
          ),
          DrawerListTile(
            title: 'Quiz Board',
            svgSrc: 'assets/icons/BlogPost.svg',
            index: 1,
            tap: () {
              controller.changePage(1);
            },
          ),
          DrawerListTile(
            title: 'Message',
            svgSrc: 'assets/icons/Message.svg',
            index: 2,
            tap: () {
              controller.changePage(2);
            },
          ),
          DrawerListTile(
            title: 'Leaderboard',
            svgSrc: 'assets/icons/Statistics.svg',
            index: 3,
            tap: () {
              controller.changePage(3);
            },
          ),
        ],
      ),
    );
  }
}
