import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visual_directions/backend/has_input.dart';

class PlaceSearchBar extends ConsumerStatefulWidget {
  const PlaceSearchBar({
    super.key,
    required this.hint,
    required this.type,
    required this.controller,
  });
  final String hint;
  final SearchfieldType type;
  final TextEditingController controller;

  @override
  ConsumerState<PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends ConsumerState<PlaceSearchBar> {
  bool hasText = false;
  @override
  Widget build(BuildContext context) {
    final hasInputManager = ref.watch(hasInputProvider.notifier);
    return Container(
      width: 400,
      child: SearchBar(
        backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.surface),
        surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
        overlayColor: MaterialStatePropertyAll(Colors.transparent),
        trailing: hasText
            ? [
                IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        hasText = false;
                        hasInputManager.onToggle(widget.type, false);
                      });
                    },
                    icon: const Icon(Icons.cancel))
              ]
            : null,
        hintText: widget.hint,
        controller: widget.controller,
        onChanged: (text) {
          hasInputManager.onToggle(widget.type, text.isNotEmpty);
          if (text.isNotEmpty == hasText) return;
          setState(() {
            hasText = text.isNotEmpty;
          });
        },
      ),
    );
  }
}
