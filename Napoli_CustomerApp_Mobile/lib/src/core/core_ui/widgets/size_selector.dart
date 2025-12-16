import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  final void Function(String)? onSelected;

  const SizeSelector({super.key, this.onSelected});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  String selected = 'S';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChoiceChip(label: const Text('S'), selected: selected == 'S', onSelected: (_) { setState(() { selected = 'S'; widget.onSelected?.call(selected); }); }),
        ChoiceChip(label: const Text('M'), selected: selected == 'M', onSelected: (_) { setState(() { selected = 'M'; widget.onSelected?.call(selected); }); }),
        ChoiceChip(label: const Text('L'), selected: selected == 'L', onSelected: (_) { setState(() { selected = 'L'; widget.onSelected?.call(selected); }); }),
      ],
    );
  }
}
