import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'show_gemini_directions.g.dart';

@riverpod
class ShowGeminiDirections extends _$ShowGeminiDirections {
  @override
  bool build() {
    return false;
  }

  void onToggle(bool value) {
    state = value;
  }
}
