import 'dart:io';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class PlaceLocation {
  const PlaceLocation(
      {required this.latitude,
      required this.longitude,
      required this.location});

  final double latitude;
  final double longitude;
  final String location;
}

class Place {
  Place({required this.name, required this.image, required this.location, id})
      : id = id ?? uuid.v4();

  final String? id;
  final String name;
  final File image;
  final PlaceLocation location;
}
