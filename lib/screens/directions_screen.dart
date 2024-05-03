import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/backend/directions_manager.dart';
import 'package:visual_directions/components/directions_switch.dart';
import 'package:visual_directions/components/main_panel.dart';
import 'package:visual_directions/components/side_panel.dart';
import 'package:visual_directions/constants.dart';

class DirectionsScreen extends StatelessWidget {
  final String origin, destination;
  const DirectionsScreen({super.key, required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: Constants.panelPadding),
            child: const DirectionsSwitch(),
          ),
        ],
        title: Row(
          children: [
            Image.asset(
              'icon.png',
              scale: 15,
            ),
            Text('Point of Reference Navigation')
          ],
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final directionsManager = ref.watch(directionsManagerProvider.notifier);
          return FutureBuilder(
            //future: directionsManager.getDirections(origin, destination),
            future: directionsManager.getDirections(origin, destination),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    SidePanel(),
                    MainPanel(),
                  ],
                );
              } else if (snapshot.hasError) {
                Navigator.pop(context);
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }
}
