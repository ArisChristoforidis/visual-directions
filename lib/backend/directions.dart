class Directions {
  final int stepIdx;
  final String gmapsDirections;
  final String geminiDirections;
  final double longitude;
  final double latitude;
  final double heading;

  Directions({required this.stepIdx, required this.gmapsDirections, required this.geminiDirections, required this.longitude, required this.latitude, required this.heading});
}
