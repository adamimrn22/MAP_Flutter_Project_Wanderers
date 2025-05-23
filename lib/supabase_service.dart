// supabase_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = 'products/$fileName.png';

    final storageResponse = await _client.storage
        .from('product-images') 
        .upload(filePath, imageFile);

    if (storageResponse.isEmpty) {
      throw Exception('Image upload failed.');
    }

    final publicUrl = _client.storage
        .from('product-images')
        .getPublicUrl(filePath);

    return publicUrl;
  }
}
