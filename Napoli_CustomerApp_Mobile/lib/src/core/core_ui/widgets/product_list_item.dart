import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/safe_image.dart';

class ProductListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String? imagePath;
  final void Function()? onTap;
  const ProductListItem({super.key, required this.title, required this.subtitle, required this.price, this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: imagePath != null && imagePath!.isNotEmpty
          ? ClipOval(
              child: SizedBox(width: 48, height: 48, child: SafeImage(assetPath: imagePath!, fit: BoxFit.cover)),
            )
          : const CircleAvatar(child: FlutterLogo()),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(price),
      onTap: onTap,
    );
  }
}
