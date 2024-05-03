import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/backend/directions.dart';
import 'package:visual_directions/backend/show_gemini_directions.dart';

class NavigationDirections extends ConsumerWidget {
  final Directions direction;
  const NavigationDirections(this.direction, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showGemini = ref.watch(showGeminiDirectionsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        showGemini ? direction.geminiDirections : direction.gmapsDirections,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
