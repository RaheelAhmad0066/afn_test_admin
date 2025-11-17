import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/controllers/notification_controller.dart';
import 'package:afn_test_admin/screens/components/custom_appbar.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize notification controller
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }
    final controller = Get.find<NotificationController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(appPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar(),
            SizedBox(height: appPadding),
            Text(
              'Send Notification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Send notifications to all users about new subject papers',
              style: TextStyle(
                fontSize: 14,
                color: lightTextColor,
              ),
            ),
            SizedBox(height: appPadding * 2),
            _NotificationForm(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _NotificationForm extends StatefulWidget {
  final NotificationController controller;

  const _NotificationForm({required this.controller});

  @override
  State<_NotificationForm> createState() => _NotificationFormState();
}

class _NotificationFormState extends State<_NotificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicIdController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _subjectController.dispose();
    _topicIdController.dispose();
    super.dispose();
  }

  void _sendNotification() {
    if (_formKey.currentState!.validate()) {
      widget.controller.sendNotificationToAllUsers(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        subjectName: _subjectController.text.trim().isEmpty 
            ? null 
            : _subjectController.text.trim(),
        topicId: _topicIdController.text.trim().isEmpty 
            ? null 
            : _topicIdController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Notification Title *',
                  hintText: 'e.g., New Math Papers Available!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: secondaryColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: appPadding),
              
              // Body Field
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notification Message *',
                  hintText: 'e.g., New practice papers for Mathematics are now available. Check them out!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: secondaryColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              SizedBox(height: appPadding),
              
              // Subject Name Field (Optional)
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject Name (Optional)',
                  hintText: 'e.g., Mathematics',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: secondaryColor,
                ),
              ),
              SizedBox(height: appPadding),
              
              // Topic ID Field (Optional)
              TextFormField(
                controller: _topicIdController,
                decoration: InputDecoration(
                  labelText: 'Topic ID (Optional)',
                  hintText: 'e.g., math_001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: secondaryColor,
                ),
              ),
              SizedBox(height: appPadding * 2),
              
              // Status Message
              if (controller.statusMessage.value.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(appPadding),
                  margin: EdgeInsets.only(bottom: appPadding),
                  decoration: BoxDecoration(
                    color: controller.isSending.value 
                        ? primaryColor.withOpacity(0.1)
                        : green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: controller.isSending.value 
                          ? primaryColor
                          : green,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (controller.isSending.value)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      else
                        Icon(Icons.check_circle, color: green, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.statusMessage.value,
                          style: TextStyle(
                            color: controller.isSending.value 
                                ? primaryColor
                                : green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Send Button
              ElevatedButton(
                onPressed: controller.isSending.value ? null : _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isSending.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Sending...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            'Send Notification to All Users',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
