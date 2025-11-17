import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/constants/responsive.dart';
import 'package:afn_test_admin/controllers/dashboard_controller.dart';
import 'analytic_info_card.dart';

class AnalyticCards extends StatelessWidget {
  const AnalyticCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize dashboard controller
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }

    Size size = MediaQuery.of(context).size;

    // Use GetBuilder instead of Obx for better control
    return GetBuilder<DashboardController>(
      builder: (controller) {
        return Container(
          child: Responsive(
            mobile: AnalyticInfoCardGridView(
              crossAxisCount: size.width < 650 ? 2 : 4,
              childAspectRatio: size.width < 650 ? 2 : 1.5,
              analytics: controller.analytics,
            ),
            tablet: AnalyticInfoCardGridView(
              analytics: controller.analytics,
            ),
            desktop: AnalyticInfoCardGridView(
              childAspectRatio: size.width < 1400 ? 1.5 : 2.1,
              analytics: controller.analytics,
            ),
          ),
        );
      },
    );
  }
}

class AnalyticInfoCardGridView extends StatelessWidget {
  const AnalyticInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1.4,
    required this.analytics,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;
  final List analytics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: analytics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: appPadding,
        mainAxisSpacing: appPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => AnalyticInfoCard(
        info: analytics[index],
      ),
    );
  }
}
