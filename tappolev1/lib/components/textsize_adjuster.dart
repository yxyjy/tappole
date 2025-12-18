import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/text_size_provider.dart';

class TextSizeAdjuster extends StatelessWidget {
  const TextSizeAdjuster({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TextSizeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Text Size", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Text("A", style: TextStyle(fontSize: 14)), // Small label
            Expanded(
              child: Slider(
                value: provider.textScale,
                min: 0.8,
                max: 1.5,
                divisions: 7, // Makes it snap to steps
                label: "${(provider.textScale * 100).round()}%",
                activeColor: const Color(0xFFF06638), // Your Orange
                onChanged: (newValue) {
                  provider.setTextScale(newValue);
                },
              ),
            ),
            const Text(
              "A",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ), // Large label
          ],
        ),
      ],
    );
  }
}
