import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/safe_image.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String category;
  final String price;
  final String? imagePath;
  final void Function()? onTap;
  const ProductCard({super.key, required this.title, required this.category, required this.price, this.imagePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use SafeImage if an image path is provided, otherwise fallback to FlutterLogo
              if (imagePath != null && imagePath!.isNotEmpty)
                SizedBox(height: 90, child: SafeImage(assetPath: imagePath!, fit: BoxFit.contain))
              else
                const FlutterLogo(size: 90),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(category, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 8),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
