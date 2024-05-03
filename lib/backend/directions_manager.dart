import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:visual_directions/backend/directions.dart';

part 'directions_manager.g.dart';

@riverpod
class DirectionsManager extends _$DirectionsManager {
  List<Directions> currentDirections = [];

  late final FirebaseFunctions _functions;
  late final HttpsCallable _getDirectionsCallable;

  late String origin, destination;

  DirectionsManager() {
    _functions = FirebaseFunctions.instance;
    _getDirectionsCallable = _functions.httpsCallable('get_directions', options: HttpsCallableOptions(timeout: const Duration(seconds: 35)));
  }

  @override
  List<Directions> build() {
    return currentDirections;
  }

  Future<List<Directions>> getDirections(String origin, String destination) async {
    HttpsCallableResult? response;
    try {
      response = await _getDirectionsCallable.call({'origin': origin, 'destination': destination});
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }
    if (response == null) return [];
    final Map data = response.data;

    final directions = <Directions>[];

    data.forEach((stepIdx, details) {
      final String gmapsDirections = details['gmaps_directions'] as String;
      final String geminiDirections = details['gemini_directions'] as String;
      final double latitude = (details['coords'] as List).first as double;
      final double longitude = (details['coords'] as List).last as double;
      final double heading = details['heading'] as double;
      final dir = Directions(
        stepIdx: int.parse(stepIdx),
        gmapsDirections: gmapsDirections,
        geminiDirections: geminiDirections,
        longitude: longitude,
        latitude: latitude,
        heading: heading,
      );
      directions.add(dir);
    });
    currentDirections = directions;
    state = currentDirections;
    return currentDirections;
  }
}
