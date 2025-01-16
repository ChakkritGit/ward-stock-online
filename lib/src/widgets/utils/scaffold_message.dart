import 'package:flutter/material.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/constants/style.dart';

class ScaffoldMessage {
  static void show(
      BuildContext context, IconData icon, String message, String success) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: success.toLowerCase() == 's'
                      ? Colors.black
                      : success.toLowerCase() == 'e'
                          ? Colors.white
                          : Colors.black,
                  size: 34.0,
                ),
                CustomGap.smallWidthGap_1,
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 24.0,
                    color: success.toLowerCase() == 's'
                        ? Colors.black
                        : success.toLowerCase() == 'e'
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: success.toLowerCase() == 's'
                    ? Colors.black
                    : success.toLowerCase() == 'e'
                        ? Colors.white
                        : Colors.black,
                size: 42.0,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        backgroundColor: success.toLowerCase() == 's'
            ? ColorsTheme.sussess
            : success.toLowerCase() == 'e'
                ? ColorsTheme.error
                : ColorsTheme.warning,
      ),
    );
  }
}
