import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService service;
  List<NotificationModel> items = [];
  bool loading = false;

  NotificationProvider({required this.service});

  Future<void> load(int userId) async {
    loading = true;
    notifyListeners();

    items = await service.getNotifications(userId);

    loading = false;
    notifyListeners();
  }

  Future<void> initPusher(int userId) async {
    await service.initPusher(
      userId: userId,
      onMessage: (notif) {
        items.insert(0, notif); // push realtime
        notifyListeners();
      },
    );
  }

  Future<void> markRead(NotificationModel n) async {
    if (!n.isRead) {
      notifyListeners();
      await service.markAsRead(n.id);
    }
  }
}
