import 'package:flutter/material.dart';

class AsyncUtils {
  static Future<void> executeSafeAsyncOperation({
    required BuildContext context,
    required Future<void> Function() asyncOperation,
    required void Function() onSuccess,
    required void Function(dynamic error) onError,
    required void Function() setLoadingState,
  }) async {
    setLoadingState();

    final currentContext = context;

    try {
      await asyncOperation();

      if (!(currentContext as Element).mounted) return;
      onSuccess();

    } catch (error) {
      if (!(currentContext as Element).mounted) return;
      onError(error);
    }
  }
}