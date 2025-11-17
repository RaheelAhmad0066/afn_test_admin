import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/constants/responsive.dart';
import 'package:afn_test_admin/controllers/controller.dart';
import 'package:afn_test_admin/controllers/dashboard_controller.dart';
import 'package:afn_test_admin/screens/components/profile_info.dart';
import 'package:afn_test_admin/screens/components/search_field.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : null;
    
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            onPressed: controller.controlMenu,
            icon: Icon(Icons.menu,color: textColor.withOpacity(0.5),),
          ),
        Expanded(child: SearchField()),
        // Refresh button for dashboard
        if (dashboardController != null)
          Obx(() => IconButton(
            onPressed: dashboardController.isLoading.value
                ? null
                : () => dashboardController.refresh(),
            icon: dashboardController.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: textColor.withOpacity(0.7),
                  ),
            tooltip: 'Refresh Dashboard',
          )),
        ProfileInfo()
      ],
    );
  }
}
