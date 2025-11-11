import 'package:flutter/material.dart';

class UIHelper {
  static void showSnackBar(BuildContext context, String message, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static OverlayEntry showLoading(BuildContext context, {String text = 'Loading...'}) {
    final overlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(dismissible: false, color: Colors.black45),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(text, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
    Overlay.of(context)?.insert(overlay);
    return overlay;
  }
}
