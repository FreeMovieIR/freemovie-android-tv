import 'package:flutter/material.dart';

import '../../gen/assets.gen.dart';

class AnnouncementBanner extends StatelessWidget {
  final FocusNode focusNode;
  final bool isFocused;

  const AnnouncementBanner({super.key, required this.focusNode, required this.isFocused});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 72),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Assets.images.icons.infoFill.svg(),
          SizedBox(width: 12),
          Text('بیانیه سلب مسئولیت', style: TextStyle(fontSize: 12)),
          Container(
            height: 3,
            width: 3,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white60),
          ),
          // Title and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ' این وب‌سایت فقط اطلاعات فیلم و سریال را نمایش می‌دهد و هیچ محتوایی را میزبانی نمی‌کند. اطلاعات از APIهای عمومی و لینک‌های دانلود از الماس مووی دریافت می‌شود',
                  style: TextStyle(fontSize: 11),
                  softWrap: true,
                ),
              ],
            ),
          ),

          // Button
          Focus(
            focusNode: focusNode,
            child: Container(
              decoration: BoxDecoration(
                color: isFocused ? Theme.of(context).colorScheme.primary : Colors.transparent,
                border: Border.all(
                    width: 1,
                    color: isFocused ? Theme.of(context).colorScheme.primary : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('اطلاعات بیشتر', style: TextStyle(fontSize: 11)),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
