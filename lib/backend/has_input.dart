import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'has_input.g.dart';

enum SearchfieldType { ORIGIN, DESTINATION }

@riverpod
class HasInput extends _$HasInput {
  bool hasOrigin = false;
  bool hasDestination = false;
  @override
  bool build() {
    return hasOrigin && hasDestination;
  }

  void reset() {
    hasOrigin = false;
    hasDestination = false;
    state = hasOrigin && hasDestination;
  }

  void onToggle(SearchfieldType key, bool value) {
    if (key == SearchfieldType.ORIGIN) {
      if (hasOrigin == value) return;
      hasOrigin = value;
    } else {
      if (hasDestination == value) return;
      hasDestination = value;
    }
    state = hasOrigin && hasDestination;
  }
}
