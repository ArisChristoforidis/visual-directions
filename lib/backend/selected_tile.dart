import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tile.g.dart';

@riverpod
class SelectedTile extends _$SelectedTile {
  @override
  int build() {
    return 0;
  }

  void setSelectedIndex(index) => state = index;
}
