import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:albrain_core/albrain_core.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final book = repo.books.where((b) => b.id == widget.bookId).isEmpty
        ? null
        : repo.books.firstWhere((b) => b.id == widget.bookId);
    final client = repo.me!;

    if (book == null) {
      return const Scaffold(
        body: Center(child: Text('Книга недоступна')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: BookCover(book: book, width: 160, height: 210)),
          const SizedBox(height: 16),
          Text('${book.title}  (${book.author})',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange)),
          const SizedBox(height: 4),
          Text('${book.price.toStringAsFixed(0)} ₽',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(book.description,
              style: const TextStyle(color: Colors.black87, height: 1.4)),
          const SizedBox(height: 16),

          const Text('Оценка книги',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            StarRating(
              rating: book.averageRating,
              onRate: (v) => repo.rateBook(book, client, v),
            ),
            const SizedBox(width: 8),
            Text('${book.averageRating.toStringAsFixed(1)} '
                '(${book.ratingsCount})'),
          ]),
          const SizedBox(height: 12),

          const Text('Оценка продавца',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            StarRating(
              rating: repo.sellerAverage(book.sellerId),
              onRate: (v) => repo.rateSeller(book.sellerId, client, v),
            ),
            const SizedBox(width: 8),
            Text('${repo.sellerAverage(book.sellerId).toStringAsFixed(1)} '
                '(${repo.sellerRatingsCount(book.sellerId)})'),
          ]),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final price = book.price.toStringAsFixed(0);
              final err = await repo.buyBook(client, book);
              messenger.showSnackBar(SnackBar(
                content: Text(
                    err ?? 'Reserve Successful! Списано $price ₽'),
              ));
            },
            child: const Text('Reserve'),
          ),
          const SizedBox(height: 24),

          const Text('Комментарии',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...book.comments.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(c.text),
                  ],
                ),
              )),
          if (book.comments.isEmpty)
            const Text('Пока нет комментариев',
                style: TextStyle(color: Colors.black45)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _commentCtrl,
                decoration:
                    const InputDecoration(hintText: 'Оставить комментарий...'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.orange),
              onPressed: () {
                final text = _commentCtrl.text.trim();
                if (text.isEmpty) return;
                repo.addComment(book, client, text);
                _commentCtrl.clear();
              },
            ),
          ]),
        ],
      ),
    );
  }
}
