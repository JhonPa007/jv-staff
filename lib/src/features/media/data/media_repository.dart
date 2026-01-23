import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/dio_client.dart';
import '../../../core/errors/exceptions.dart';

part 'media_repository.g.dart';

@riverpod
MediaRepository mediaRepository(MediaRepositoryRef ref) {
  return MediaRepository(ref.watch(dioClientProvider));
}

class MediaRepository {
  final Dio _dio;

  MediaRepository(this._dio);

  Future<String> uploadImage(XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/media/upload', // Using relative path as base URL is configured in Dio
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      } else {
        throw ServerException('Failed to upload image');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error during upload');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
