import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/backend/directions_manager.dart';
import 'package:visual_directions/components/directions_tile.dart';
import 'package:visual_directions/constants.dart';

class SidePanel extends ConsumerWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size * 0.25;
    final directions = ref.watch(directionsManagerProvider);
    return Padding(
      padding: Constants.sidePanelPadding,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: Constants.panelBorderRadius,
        ),
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: Constants.sidePanelElementPadding,
              child: Text(
                'Navigation Directions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => DirectionsTile(index: index),
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.background,
                  thickness: 2,
                ),
                itemCount: directions.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
