import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visual_directions/backend/show_gemini_directions.dart';

class DirectionsSwitch extends ConsumerWidget {
  const DirectionsSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showGemini = ref.watch(showGeminiDirectionsProvider);
    final showGeminiManager = ref.watch(showGeminiDirectionsProvider.notifier);
    return Row(
      children: [
        Text(
          showGemini ? 'Gemini Navigation' : 'Default Navigation',
          style: TextStyle(
            color: showGemini ? Color(0xff4289cb) : Colors.black,
            fontSize: 16,
          ),
        ),
        Switch(
          activeColor: Theme.of(context).primaryColor,
          inactiveThumbColor: Colors.black38,
          inactiveTrackColor: Colors.black12,
          trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          value: showGemini,
          onChanged: (value) => showGeminiManager.onToggle(!showGemini),
          thumbIcon: MaterialStateProperty.all<Icon>(Icon(showGemini ? FontAwesomeIcons.microchip : FontAwesomeIcons.route)),
        ),
      ],
    );
  }
}
