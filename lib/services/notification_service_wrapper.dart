import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationServiceWrapper {
  int notifcationId = 0;
  createNotification(NotificationContent content) {
    AwesomeNotifications().createNotification(content: content);
    notifcationId = notifcationId + 1;
  }
}
