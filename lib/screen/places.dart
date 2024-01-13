import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favorite_places/providers/your_places_provider.dart';
import 'package:favorite_places/widgets/loading_area.dart';
import 'package:favorite_places/models/places.dart';
import 'package:favorite_places/screen/add_place.dart';
import 'package:favorite_places/screen/place_detail.dart';
import 'package:favorite_places/widgets/place_item.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesState();
}

class _PlacesState extends ConsumerState<PlacesScreen> {
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    loadYourPlaces();
  }

  loadYourPlaces() {
    _placesFuture = ref.read(yourPlacesProvider.notifier).getYourPlaces();
  }

  goToAddPlaceScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AddPlace(),
      ),
    );
  }

  goToPlaceDetail(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PlaceDetail(place: place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placesList = ref.watch(yourPlacesProvider);
    Widget loadingWidget(bool isLoading) {
      return Center(
        child:
            LoadingArea(isLoading: isLoading, loadYourPlaces: loadYourPlaces),
      );
    }

    Widget listWidget = RefreshIndicator(
      onRefresh: () async {
        await loadYourPlaces();
      },
      child: placesList.isEmpty
          ? loadingWidget(false)
          : ListView.builder(
              itemBuilder: (ctx, index) => InkWell(
                child: Dismissible(
                  key: ValueKey(placesList[index].id),
                  confirmDismiss: (dismissDirection) async {
                    ref
                        .read(yourPlacesProvider.notifier)
                        .removeYourPlace(placesList[index]);
                    return true;
                  },
                  onDismissed: (dismissDirection) {
                    //
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PlaceItem(place: placesList[index]),
                  ),
                ),
                onTap: () {
                  goToPlaceDetail(placesList[index]);
                },
              ),
              itemCount: placesList.length,
            ),
    );

    Widget contentScreen = FutureBuilder(
      future: _placesFuture,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? loadingWidget(true)
              : listWidget,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            onPressed: goToAddPlaceScreen,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: contentScreen,
    );
  }
}
