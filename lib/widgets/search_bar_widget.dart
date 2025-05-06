import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/product_provider.dart';
import '../models/category_type.dart';
import '../services/connectivity_service.dart';

class SearchBarWidget extends StatefulWidget {
  final CategoryType? initialCategory;

  const SearchBarWidget({super.key, this.initialCategory});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject.seeded('');
  final BehaviorSubject<CategoryType?> _categorySubject = BehaviorSubject<CategoryType?>();
  late final Stream<List<String>> _suggestionsStream;
  late final ProductProvider productProvider;

  StreamSubscription<bool>? _internetSub;
  bool? _lastInternetStatus;

  @override
  void initState() {
    super.initState();

    productProvider = context.read<ProductProvider>();
    final initialCat = widget.initialCategory ?? productProvider.selectedCategory;
    _categorySubject.add(initialCat);

    _suggestionsStream = Rx.combineLatest2<String, CategoryType?, void>(
      _searchSubject.debounceTime(const Duration(milliseconds: 400)).distinct(),
      _categorySubject.distinct(),
          (query, category) {
        productProvider.searchWithCategory(query: query, category: category);
      },
    ).switchMap((_) {
      return productProvider.searchedProductsStream.map((products) {
        return products.map((p) => p.name).toSet().take(5).toList();
      });
    });

    _controller.addListener(() {
      final text = _controller.text.trim();
      if (_searchSubject.value != text) {
        _searchSubject.add(text);
      }
    });

    //  Listen to internet status and show SnackBar
    final connectivityService = context.read<ConnectivityService>();
    _internetSub = connectivityService.internetStatusStream.listen((hasInternet) {
      if (_lastInternetStatus != hasInternet) {
        final message = hasInternet
            ? 'Internet connected'
            : 'Internet lost. Some features may not work.';
        final color = hasInternet ? Colors.green : Colors.red;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        _lastInternetStatus = hasInternet;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchSubject.close();
    _categorySubject.close();
    _internetSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = CategoryType.values;
    final connectivityService = context.watch<ConnectivityService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _searchSubject.add('');
                    },
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButton<CategoryType?>(
          value: _categorySubject.valueOrNull,
          hint: const Text("Select Category"),
          isExpanded: true,
          items: [
            const DropdownMenuItem<CategoryType?>(
              value: null,
              child: Text("All Categories"),
            ),
            ...categoryOptions.map((cat) => DropdownMenuItem<CategoryType>(
              value: cat,
              child: Text(cat.label),
            )),
          ],
          onChanged: (selected) {
            _categorySubject.add(selected);
          },
        ),
        const SizedBox(height: 10),
        // Listen to internet stream and only show suggestions if connected
        StreamBuilder<bool>(
          stream: connectivityService.internetStatusStream,
          builder: (context, snapshot) {
            final hasInternet = snapshot.data ?? false;
            if (!hasInternet) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No internet connection. Try again later.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
//show suggestions if connected this is our subscriber
            return StreamBuilder<List<String>>(
              stream: _suggestionsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final suggestions = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        _controller.text = suggestion;
                        _searchSubject.add(suggestion);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
