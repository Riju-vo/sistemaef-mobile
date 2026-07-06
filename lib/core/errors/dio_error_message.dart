import 'package:dio/dio.dart';

String extractDioErrorMessage(Object error, String fallbackMessage) {
  if (error is DioException) {
    final responseData = error.response?.data;

    if (responseData is Map) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      if (message is List) {
        final joined = message
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .join(', ');
        if (joined.isNotEmpty) {
          return joined;
        }
      }

      final errorField = responseData['error'];
      if (errorField is String && errorField.trim().isNotEmpty) {
        return errorField.trim();
      }
    }

    final dioMessage = error.message?.trim();
    if (dioMessage != null &&
        dioMessage.isNotEmpty &&
        dioMessage.toLowerCase() != 'null') {
      return dioMessage;
    }

    return fallbackMessage;
  }

  final generic = error.toString().replaceFirst('Exception: ', '').trim();
  return generic.isNotEmpty ? generic : fallbackMessage;
}
