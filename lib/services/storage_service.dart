import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final SupabaseClient _supabase;
  final String _bucketName = 'product-images';

  StorageService() : _supabase = Supabase.instance.client;

  Future<void> initializeBucket() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);

      if (!bucketExists) {
        await _supabase.storage.createBucket(
          _bucketName,
          const BucketOptions(
            public: true,
            fileSizeLimit: '5242880', // 5MB in string format
          ),
        );
      }
    } catch (e) {
      print('Error initializing bucket: $e');
      rethrow;
    }
  }

  Future<String> uploadProductImage(dynamic imageFile) async {
    try {
      late String fileName;
      late Uint8List bytes;

      if (imageFile is! XFile) {
        throw Exception('Invalid file type. Expected XFile.');
      }

      bytes = await imageFile.readAsBytes();
      fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.name)}';

      // Upload the file
      final uploadPath = await _supabase.storage.from(_bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get the public URL
      final imageUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      print('Uploaded image URL: $imageUrl'); // Debug print
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final fileName = path.basename(uri.path);

      await _supabase.storage.from(_bucketName).remove([fileName]);
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }
}
