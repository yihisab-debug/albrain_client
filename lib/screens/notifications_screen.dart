import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:albrain_core/albrain_core.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final orders = repo.ordersForUser(repo.me!.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown)),
            const SizedBox(height: 12),
            Expanded(
              child: orders.isEmpty
                  ? const Center(
                      child: Text('Empty\nУ вас пока нет уведомлений',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black45)),
                    )
                  : ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final o = orders[i];
                        final refunded = o.status == OrderStatus.refunded;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.orange.withValues(alpha: 0.15),
                            child: const Icon(Icons.book,
                                color: AppColors.orange),
                          ),
                          title: Text('Вы зарезервировали «${o.bookTitle}»'),
                          subtitle: Text(refunded
                              ? 'Возврат выполнен'
                              : '${o.amount.toStringAsFixed(0)} ₽'),
                          trailing: refunded
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
