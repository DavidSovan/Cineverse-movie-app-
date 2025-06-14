import 'package:cineverse/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_multi_provider.dart';
import '../widgets/search_result_item.dart';

class SearchMultiScreen extends StatelessWidget {
  const SearchMultiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SearchMultiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search movies or shows...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    if (query.length > 2) {
                      provider.search(query);
                    }
                  },
                ),
                if (provider.searchHistory.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Searches",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => provider.clearSearchHistory(),
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: provider.searchHistory.map((query) {
                      return ActionChip(
                        label: Text(query),
                        onPressed: () => provider.search(query),
                      );
                    }).toList(),
                  ),
                ]
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : provider.results.isEmpty
                        ? const Center(child: Text('No results found'))
                        : ListView.builder(
                            itemCount: provider.results.length,
                            itemBuilder: (context, index) {
                              return SearchResultItem(
                                  result: provider.results[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
