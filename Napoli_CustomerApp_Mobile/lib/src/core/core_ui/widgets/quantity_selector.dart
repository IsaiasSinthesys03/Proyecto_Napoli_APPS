import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final void Function(int)? onChanged;

  const QuantitySelector({super.key, this.initialValue = 0, this.onChanged});

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  void _increment() {
    setState(() {
      value++;
    });
    widget.onChanged?.call(value);
  }

  void _decrement() {
    if (value <= 0) return;
    setState(() {
      value--;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: _decrement, icon: const Icon(Icons.remove)),
        Text(value.toString()),
        IconButton(onPressed: _increment, icon: const Icon(Icons.add)),
      ],
    );
  }
}
