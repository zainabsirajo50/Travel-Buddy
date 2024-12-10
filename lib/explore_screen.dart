import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart' as gms;

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late GoogleMapController mapController;
  loc.Location location = loc.Location();
  LatLng _currentLocation = LatLng(37.7749, -122.4194); // Default to San Francisco
  Set<Marker> _markers = {};
  final String apiKey = 'AIzaSyBCHBCwllNtTqu0JBkCOOofOdCPZCMLw0U'; 
  TextEditingController _searchController = TextEditingController();
  
  // List to store tourist attractions
  List<gms.PlacesSearchResult> _touristAttractions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fetch Current Location
  Future<void> _getCurrentLocation() async {
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    var permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    var currentLocation = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
    });

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 14),
      ),
    );

    _fetchNearbyAttractions();
  }

  // Fetch Nearby Attractions
  Future<void> _fetchNearbyAttractions() async {
    final gms.GoogleMapsPlaces places = gms.GoogleMapsPlaces(apiKey: apiKey);

    final gms.PlacesSearchResponse response = await places.searchNearbyWithRadius(
      gms.Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
      1000, // 1km radius
      type: 'tourist_attraction', 
    );

    if (response.results.isNotEmpty) {
      setState(() {
        _touristAttractions = response.results; // Store tourist attractions
        _markers.clear(); // Clear old markers
        response.results.forEach((place) {
          _markers.add(
            Marker(
              markerId: MarkerId(place.placeId!),
              position: LatLng(
                place.geometry!.location.lat,
                place.geometry!.location.lng,
              ),
              infoWindow: InfoWindow(
                title: place.name,
                snippet: place.vicinity,
              ),
            ),
          );
        });
      });
    }
  }

  // Fetch Place Details for Search
  Future<void> _getPlaceDetails(String placeId) async {
    final gms.GoogleMapsPlaces places = gms.GoogleMapsPlaces(apiKey: apiKey);

    final gms.PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);
    if (detail.result.geometry != null) {
      final LatLng searchedLocation = LatLng(
        detail.result.geometry!.location.lat,
        detail.result.geometry!.location.lng,
      );

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: searchedLocation, zoom: 14),
        ),
      );

      setState(() {
        _currentLocation = searchedLocation;
        _markers.add(
          Marker(
            markerId: MarkerId(placeId),
            position: searchedLocation,
            infoWindow: InfoWindow(
              title: detail.result.name,
              snippet: detail.result.formattedAddress,
            ),
          ),
        );
      });

      _fetchNearbyAttractions();
    }
  }

  // Handle Search Submission
  Future<void> _onSearchSubmitted(String query) async {
    final gms.GoogleMapsPlaces places = gms.GoogleMapsPlaces(apiKey: apiKey);

    final gms.PlacesAutocompleteResponse response = await places.autocomplete(query);
    if (response.predictions.isNotEmpty) {
      final firstPrediction = response.predictions.first;
      _getPlaceDetails(firstPrediction.placeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Nearby'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for places...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _onSearchSubmitted(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Google Map displaying the markers
                Expanded(
                  flex: 3,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation,
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    markers: _markers,
                  ),
                ),
                // List of Tourist Attractions
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _touristAttractions.length,
                    itemBuilder: (context, index) {
                      final place = _touristAttractions[index];
                      return ListTile(
                        title: Text(place.name ?? 'Unknown Place'),
                        subtitle: Text(place.vicinity ?? 'No Address Available'),
                        onTap: () {
                          _getPlaceDetails(place.placeId!);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
