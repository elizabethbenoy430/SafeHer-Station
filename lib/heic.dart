import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class HeicImage extends StatelessWidget {
  final String imageUrl;
  const HeicImage({super.key, required this.imageUrl});

  Future<File?> _processImage() async {
    try {
      // 1. Download file to cache
      final File file = await DefaultCacheManager().getSingleFile(imageUrl);
      
      // 2. Check if it's HEIC
      if (imageUrl.toLowerCase().endsWith('.heic') || imageUrl.toLowerCase().endsWith('.heif')) {
        final tempDir = await getTemporaryDirectory();
        final targetPath = p.join(tempDir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

        // 3. Convert HEIC to JPG
        var result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          format: CompressFormat.jpeg,
          quality: 90,
        );

        return result != null ? File(result.path) : null;
      } else {
        // 4. If it's already JPG/PNG, just return it
        return file;
      }
    } catch (e) {
      debugPrint("Image Processing Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _processImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent));
        }
        
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white24, size: 40),
                SizedBox(height: 8),
                Text("Unable to load HEIC", style: TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          );
        }

        return Image.file(
          snapshot.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
      },
    );
  }
}