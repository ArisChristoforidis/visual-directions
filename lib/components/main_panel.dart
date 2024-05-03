import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/auth/secrets.dart';
import 'package:visual_directions/backend/directions.dart';
import 'package:visual_directions/backend/directions_manager.dart';
import 'package:visual_directions/backend/selected_tile.dart';
import 'package:visual_directions/components/navigation_card.dart';
import 'package:visual_directions/constants.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class MainPanel extends ConsumerWidget {
  final PlatformWebViewController _controller = PlatformWebViewController(
    const PlatformWebViewControllerCreationParams(),
  )..loadRequest(
      LoadRequestParams(
        uri: Uri.parse('https://flutter.dev'),
      ),
    );
  MainPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTileIndex = ref.watch(selectedTileProvider);
    final directions = ref.watch(directionsManagerProvider);
    print("rebuild main panel!, directions: $directions");
    return Expanded(
      child: Padding(
        padding: Constants.mainPanelPadding,
        child: Container(
          decoration: BoxDecoration(borderRadius: Constants.panelBorderRadius),
          child: ClipRRect(
            borderRadius: Constants.panelBorderRadius,
            child: directions.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      _getStreetViewWidget(context, directions[selectedTileIndex]),
                      NavigationCard(
                        direction: directions[selectedTileIndex],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _getStreetViewWidget(BuildContext context, Directions direction) {
    _controller.loadRequest(
      LoadRequestParams(
        uri: Uri.parse("https://www.google.com/maps/embed/v1/streetview?key=${DIRECTIONS_API_KEY}&heading=${direction.heading}&location=${direction.latitude},${direction.longitude}"),
      ),
    );
    return PlatformWebViewWidget(
      PlatformWebViewWidgetCreationParams(controller: _controller),
    ).build(context);
  }
}
