import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:albrain_core/albrain_core.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final client = repo.me!;
    final orders = repo.ordersForUser(client.id);
    final complaints = repo.complaintsForUser(client.id);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            const CircleAvatar(radius: 26, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(client.email,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Выйти',
              icon: const Icon(Icons.logout, color: AppColors.brown),
              onPressed: () => repo.signOut(),
            ),
          ]),
          const SizedBox(height: 16),
          BalanceCard(
            balance: client.balance,
            onTopUp: () => repo.topUp(client),
          ),
          const SizedBox(height: 20),
          const Text('Мои заказы',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (orders.isEmpty)
            const Text('Заказов пока нет',
                style: TextStyle(color: Colors.black45)),
          ...orders.map((o) => _OrderTile(order: o)),
          const SizedBox(height: 20),
          const Text('Мои жалобы',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (complaints.isEmpty)
            const Text('Жалоб нет', style: TextStyle(color: Colors.black45)),
          ...complaints.map((c) {
            final (label, color) = switch (c.status) {
              ComplaintStatus.pending => ('На рассмотрении', Colors.orange),
              ComplaintStatus.accepted => (
                  'Принята — деньги возвращены',
                  Colors.green
                ),
              ComplaintStatus.rejected => ('Отклонена', Colors.red),
            };
            return Card(
              child: ListTile(
                title: Text(c.bookTitle),
                subtitle: Text(c.text),
                trailing:
                    Text(label, style: TextStyle(color: color, fontSize: 12)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppRepository>();
    final refunded = order.status == OrderStatus.refunded;
    return Card(
      child: ListTile(
        title: Text(order.bookTitle),
        subtitle: Text('${order.amount.toStringAsFixed(0)} ₽'
            '${refunded ? '  •  возвращено' : ''}'),
        trailing: refunded
            ? const Icon(Icons.verified, color: Colors.green)
            : TextButton(
                onPressed: () => _showComplaintDialog(context, repo, order),
                child: const Text('Жалоба',
                    style: TextStyle(color: AppColors.orange)),
              ),
      ),
    );
  }

  void _showComplaintDialog(
      BuildContext context, AppRepository repo, Order order) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Жалоба на «${order.bookTitle}»'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Опишите проблему (требуется возврат денег)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              repo.fileComplaint(repo.me!, order, text);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Жалоба отправлена админу на рассмотрение'),
              ));
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}
