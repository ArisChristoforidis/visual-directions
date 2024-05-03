import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/backend/directions.dart';
import 'package:visual_directions/backend/directions_manager.dart';
import 'package:visual_directions/backend/show_gemini_directions.dart';

class NavigationCard extends ConsumerWidget {
  final Directions direction;
  const NavigationCard({super.key, required this.direction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showGemini = ref.watch(showGeminiDirectionsProvider);
    final stepCount = ref.watch(directionsManagerProvider).length;
    return Positioned(
      bottom: 16,
      left: 16,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        child: Container(
          width: 400,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${direction.stepIdx} of $stepCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    showGemini ? direction.geminiDirections : direction.gmapsDirections,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
