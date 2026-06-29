import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:albrain_core/albrain_core.dart';

import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final List<Book> results = _query.isEmpty
        ? repo.books
        : repo.books
            .where((b) =>
                b.title.toLowerCase().contains(_query.toLowerCase()) ||
                b.author.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown)),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search For Books',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 16),
            const Text('Trending',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final b = results[i];
                  return ListTile(
                    leading: const Icon(Icons.book_outlined,
                        color: AppColors.orange),
                    title: Text(b.title),
                    subtitle: Text(b.author),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BookDetailScreen(bookId: b.id))),
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
