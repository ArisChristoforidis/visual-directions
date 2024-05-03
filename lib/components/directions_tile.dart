import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/auth/secrets.dart';
import 'package:visual_directions/backend/directions_manager.dart';
import 'package:visual_directions/backend/selected_tile.dart';
import 'package:visual_directions/backend/show_gemini_directions.dart';

class DirectionsTile extends ConsumerWidget {
  final index;
  const DirectionsTile({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTileIndex = ref.watch(selectedTileProvider);
    final directions = ref.watch(directionsManagerProvider)[index];
    return ListTile(
      selectedColor: Theme.of(context).primaryColor,
      leading: Container(
        width: 50,
        height: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            "https://maps.googleapis.com/maps/api/streetview?size=400x400&location=${directions.latitude},${directions.longitude}&fov=70&heading=10&pitch=0&key=$DIRECTIONS_API_KEY",
          ),
        ),
      ),
      title: Text(
        'Step ${index + 1}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: selectedTileIndex == index ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Consumer(
        builder: (context, ref, child) {
          final showGeminiDirections = ref.watch(showGeminiDirectionsProvider);
          return Text(showGeminiDirections ? directions.geminiDirections : directions.gmapsDirections);
        },
      ),
      selected: selectedTileIndex == index,
      onTap: () {
        ref.read(selectedTileProvider.notifier).setSelectedIndex(index);
      },
    );
  }
}
