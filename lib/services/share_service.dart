import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Share text + optional image
  static Future<void> shareProduct({
    required String text,
    String? imageUrl,
  }) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final uri = Uri.parse(imageUrl);
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/shared_image.jpg');
          await file.writeAsBytes(response.bodyBytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: text,
          );
          return;
        }
      }

      // fallback: share text only
      await Share.share(text);
    } catch (e) {
      debugPrint("Error while sharing: $e");
      await Share.share(text);
    }
  }
}
