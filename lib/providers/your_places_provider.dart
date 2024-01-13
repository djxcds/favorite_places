import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/places.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final String dbPath = await sql.getDatabasesPath();
  return await sql.openDatabase(path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE user_places(id TEXT Primary KEY, name TEXT, image TEXT, lat REAL, lng REAL, location TEXT)');
  }, version: 1);
}

class YourPlacesNotifier extends StateNotifier<List<Place>> {
  YourPlacesNotifier() : super([]);

  void addYourPlace(Place place) async {
    final Directory appDir = await syspaths.getApplicationDocumentsDirectory();
    final String filename = path.basename(place.image.path);
    final copiedImage = await place.image.copy('${appDir.path}/$filename');

    state = [
      ...state,
      Place(name: place.name, image: copiedImage, location: place.location)
    ];

    final db = await _getDatabase();
    db.insert('user_places', {
      'id': place.id,
      'name': place.name,
      'image': copiedImage.path,
      'lat': place.location.latitude,
      'lng': place.location.longitude,
      'location': place.location.location
    });
  }

  getYourPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            name: row['name'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
                latitude: row['lat'] as double,
                longitude: row['lng'] as double,
                location: row['location'] as String),
          ),
        )
        .toList();
    List<Place> list = places;
    print('loading data');
    print(places);
    state = list;
  }

  removeYourPlace(Place place) {
    List<Place> newList = [...state];
    newList.remove(place);
    state = newList;
  }
}

final yourPlacesProvider =
    StateNotifierProvider<YourPlacesNotifier, List<Place>>(
        (ref) => YourPlacesNotifier());
