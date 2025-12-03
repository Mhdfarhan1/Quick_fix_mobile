import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notificationprovider.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;


class NotificationPage extends StatelessWidget {
  final int userId;

  const NotificationPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final prov = NotificationProvider(service: NotificationService());
        prov.load(userId);
        prov.initPusher(userId);
        return prov;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C4481),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text("Notifikasi"),
        ),
        body: const _NotificationList(),
      ),
    );
  }
}


class _NotificationList extends StatelessWidget {
  const _NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NotificationProvider>(context);

    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prov.items.length,
      itemBuilder: (_, i) {
        return _NotificationItem(item: prov.items[i]);
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel item;

  const _NotificationItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NotificationProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => prov.markRead(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 3),
              blurRadius: 9,
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT SIDE (TEXTS)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: item.isRead ?
                          Colors.grey[700] :
                          const Color(0xFF0C4481),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.pesan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE (TIME)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                timeago.format(
                  DateTime.parse(item.createdAt),
                  locale: 'id_short',
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}