import 'dart:io';

import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/models/places.dart';
import 'package:favorite_places/providers/your_places_provider.dart';

class AddPlace extends ConsumerStatefulWidget {
  const AddPlace({super.key});

  @override
  ConsumerState<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends ConsumerState<AddPlace> {
  String place = '';
  final TextEditingController _placeController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  addYourPlace() {
    final placeToAdd = _placeController.text;

    if (placeToAdd.isEmpty ||
        _selectedImage == null ||
        _selectedLocation == null) {
      return;
    }

    ref.read(yourPlacesProvider.notifier).addYourPlace(Place(
        name: _placeController.text,
        image: _selectedImage!,
        location: _selectedLocation!));
    if (!context.mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _placeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
        actions: [
          ElevatedButton(
            onPressed: addYourPlace,
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))))),
            child: const Text('Add'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _placeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Name'),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            LocationInput(selectedLocation: (location) {
              _selectedLocation = location;
            }),
            const SizedBox(
              height: 8,
            ),
            ImageInput(
              onPickImage: (image) {
                _selectedImage = image;
              },
            )
          ],
        ),
      ),
    );
  }
}
