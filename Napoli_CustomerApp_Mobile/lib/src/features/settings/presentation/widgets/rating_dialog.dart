import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final ValueChanged<int> onRate;

  const RatingDialog({super.key, required this.onRate});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int selectedRating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calificar Pedido'), // Should be localized
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '¿Cómo fue tu experiencia con este pedido?', // Should be localized
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () {
                  setState(() {
                    selectedRating = index + 1;
                  });
                },
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'), // Should be localized
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onRate(selectedRating);
          },
          child: const Text('Calificar'), // Should be localized
        ),
      ],
    );
  }
}
