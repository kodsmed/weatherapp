import 'package:flutter/material.dart';

String getCompassDirection(double windDirection, String lang) {
  List<String> directions;
  if (lang == 'sv') {
    directions = [
      'N', 'NNO', 'NO', 'ONO', 'O', 'OSO', 'SO', 'SSO',
      'S', 'SSV', 'SV', 'VSV', 'V', 'VNV', 'NV', 'NNV'
    ];
  } else {
    directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
  }

  // Ensure degrees are within [0, 360]
  windDirection %= 360;

  // Calculate the index in the directions list
  final int index = ((windDirection + 11.25) % 360 / 22.5).round();

  return directions[index];
}

class WindDirectionArrow extends StatelessWidget {
  final double windDirection; // Wind direction in degrees (0 to 360)

  const WindDirectionArrow({required this.windDirection ,required Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double rotationAngle = windDirection;

    return Transform.rotate(
      angle: rotationAngle,
      child: const Icon(
        Icons.straight,
        size: 32,
      ),
    );
  }
}