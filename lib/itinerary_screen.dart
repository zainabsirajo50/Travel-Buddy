import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'explore_screen.dart'; // Import the ExploreScreen
=======
import 'package:firebase_auth/firebase_auth.dart';
>>>>>>> c5898ae3ad23a30f37d5ad7d325ae8c831f4f370

class ItineraryListScreen extends StatefulWidget {
  @override
  _ItineraryListScreenState createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> userPreferences = [];
  List<String> userActivities = [];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userPreferences = List<String>.from(doc.data()?['preferences'] ?? []);
          userActivities = List<String>.from(doc.data()?['activities'] ?? []);
        });
      }
    }
  }

  Future<List<DocumentSnapshot>> _getTailoredItineraries() async {
    // Retrieve all itineraries from Firestore
    QuerySnapshot querySnapshot = await _firestore.collection('itineraries').get();
    List<DocumentSnapshot> itineraries = querySnapshot.docs;

    // If no preferences are saved, show all itineraries
    if (userPreferences.isEmpty && userActivities.isEmpty) {
      return itineraries;
    }

    // Filter itineraries based on user preferences and activities
    return itineraries.where((itinerary) {
      List<dynamic> itineraryPreferences = itinerary['preferences'] ?? [];
      List<dynamic> itineraryActivities = itinerary['activities'] ?? [];

      // Match preferences or activities (OR condition)
      bool matchesPreferences = itineraryPreferences.any((pref) => userPreferences.contains(pref));
      bool matchesActivities = itineraryActivities.any((activity) => userActivities.contains(activity));

      // If either preference or activity matches, show the itinerary
      return matchesPreferences || matchesActivities;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Itinerary Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // Navigate to the Explore Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExploreScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(labelText: 'Destination'),
                ),
                TextField(
                  controller: _activityController,
                  decoration: const InputDecoration(labelText: 'Activity'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addItinerary,
                  child: const Text('Add Itinerary'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Explore Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExploreScreen()),
                    );
                  },
                  child: const Text('Explore Nearby'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _itinerariesCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No itineraries available.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    final data = document.data() as Map<String, dynamic>;
                    final id = document.id;
                    final destination = data['destination'] ?? 'Unknown';
                    final activities =
                        List<String>.from(data['activities'] ?? []);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ExpansionTile(
                        title: Text(destination),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...activities.map((activity) => ListTile(
                                    title: Text(activity),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          activities.remove(activity);
                                          _updateItinerary(id, activities);
                                        });
                                      },
                                    ),
                                  )),
                              ListTile(
                                title: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Add Activity'),
                                  onSubmitted: (newActivity) {
                                    if (newActivity.isNotEmpty) {
                                      setState(() {
                                        activities.add(newActivity);
                                        _updateItinerary(id, activities);
                                      });
                                    }
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: () => _deleteItinerary(id),
                                child: const Text(
                                  'Delete Itinerary',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
=======
      appBar: AppBar(title: Text("Tailored Itineraries")),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getTailoredItineraries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No itineraries available"));
          } else {
            List<DocumentSnapshot> itineraries = snapshot.data!;
            return ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                var itinerary = itineraries[index];
                return ListTile(
                  title: Text(itinerary['title']),
                  subtitle: Text(itinerary['description']),
                  onTap: () {
                    // Navigate to itinerary detail screen
                  },
>>>>>>> c5898ae3ad23a30f37d5ad7d325ae8c831f4f370
                );
              },
            );
          }
        },
      ),
    );
  }
}
