import 'package:flutter/material.dart';

class LoadingArea extends StatelessWidget {
  const LoadingArea(
      {super.key, required this.isLoading, required this.loadYourPlaces});

  final bool isLoading;
  final void Function() loadYourPlaces;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  ),
                ),
              Text(
                isLoading ? 'Fetching data' : 'No data to display.',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        if (!isLoading)
          ElevatedButton(
            onPressed: loadYourPlaces,
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))))),
            child: const Text('Refresh'),
          )
      ],
    );
  }
}
