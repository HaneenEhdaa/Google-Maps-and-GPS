import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final List<Marker> _markers = <Marker>[];
  bool mapLoading = true;
  Position? myLocation;
  late CameraPosition myCameraPosition;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Google Map",
          style: TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.w300),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: mapLoading || myLocation == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: myCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: Set<Marker>.of(_markers),
            ),
    );
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    myLocation = await Geolocator.getCurrentPosition();

    myCameraPosition = CameraPosition(
      target: LatLng(30.045916, 31.224291),
      zoom: 14.4746,
    );
    _markers.add(Marker(
        markerId: MarkerId('SomeId'),
        position: LatLng(30.045916, 31.224291),
        infoWindow: InfoWindow(title: 'Cairo Government in Egypt')));
    setState(() {
      mapLoading = false;
    });
  }
}
