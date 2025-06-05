import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);
    final location = provider.location;
    final isLoading = provider.isLoading;
    final error = provider.errorMessage;

    if (isLoading) {
      return const SizedBox(
        width: 100,
        height: 20,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (error != null) {
      return Text(
        error,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
        ),
      );
    }

    if (location == null) {
      return const Text(
        'Location unavailable',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      );
    }

    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            location.address,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}
