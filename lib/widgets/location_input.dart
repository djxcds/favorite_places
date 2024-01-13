import 'dart:convert';
import 'package:favorite_places/screen/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:favorite_places/models/places.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.selectedLocation});
  final void Function(PlaceLocation location) selectedLocation;

  @override
  State<StatefulWidget> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;
  final String apiKey = 'AIzaSyDIoX41bbUWoW7ADkw99EThlePWwwkV_GE';

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=colorScheme.background:blue%7Clabel:S%7C$lat,$lng&key=$apiKey';
  }

  void _saveLocation(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];

    setState(() {
      final PlaceLocation location = PlaceLocation(
          latitude: latitude, longitude: longitude, location: address);
      widget.selectedLocation(location);
      _pickedLocation = location;
      _isGettingLocation = false;
    });
  }

  void _getCurrentLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      setState(() {
        _isGettingLocation = true;
      });

      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat == null || lng == null) {
        return;
      }

      _saveLocation(lat, lng);
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  _setManualLocation(LatLng latlng) async {
    try {
      setState(() {
        _isGettingLocation = true;
      });

      _saveLocation(latlng.latitude, latlng.longitude);
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  _onSelectMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => MapScreen(
          isSelecting: true,
          selectMap: (latlng) {
            _setManualLocation(latlng);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location Chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(locationImage,
          fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          height: 170,
          width: double.infinity,
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Get Current Location')),
            TextButton.icon(
                onPressed: _onSelectMap,
                icon: const Icon(Icons.map),
                label: const Text('Select on Map'))
          ],
        ),
      ],
    );
  }
}
