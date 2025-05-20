import 'package:flutter/material.dart';

class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final bool isLoading;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator();
    }

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        return ListTile(
          title: Text(suggestions[i]),
          onTap: () => onSuggestionTap(suggestions[i]),
        );
      },
    );
  }
}
