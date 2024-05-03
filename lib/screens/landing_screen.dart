import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/backend/has_input.dart';
import 'package:visual_directions/components/place_search_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visual_directions/screens/directions_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController originController = TextEditingController();
  final destinationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Column(
                children: [
                  Animate(
                    onPlay: (controller) => controller.repeat(),
                    effects: [ShimmerEffect(duration: Duration(milliseconds: 350), delay: Duration(seconds: 5))],
                    child: Image.asset(
                      'icon.png',
                      scale: 2,
                    ),
                  ),
                  AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Point of Reference Navigation',
                        textStyle: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff4289cb),
                        ),
                      ),
                      TypewriterAnimatedText(
                        'Plot a Route',
                        textStyle: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff885ea2),
                        ),
                      ),
                    ],
                    pause: const Duration(seconds: 5),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 450),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PlaceSearchBar(
                        type: SearchfieldType.ORIGIN,
                        hint: 'Where are you currently?',
                        controller: originController,
                      ),
                      PlaceSearchBar(
                        type: SearchfieldType.DESTINATION,
                        hint: 'Where are you going next?',
                        controller: destinationController,
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final hasInput = ref.watch(hasInputProvider);
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(250, 75),
                          backgroundColor: Theme.of(context).primaryColor,
                          surfaceTintColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                        ),
                        onPressed: hasInput
                            ? () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DirectionsScreen(origin: originController.text, destination: destinationController.text),
                                    ));
                              }
                            : null,
                        child: Text(
                          'Get directions',
                          style: TextStyle(
                            fontSize: 18,
                            color: hasInput ? Colors.white : Colors.black45,
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }
}
