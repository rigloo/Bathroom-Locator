
import 'package:bathroom_locator/helpers/geoLocatorHelper.dart';
import 'package:bathroom_locator/helpers/location_helper.dart';
import 'package:bathroom_locator/helpers/loggerHelper.dart';
import 'package:bathroom_locator/models/bathroom.dart';
import 'package:bathroom_locator/models/location.dart';
import 'package:bathroom_locator/models/review.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Bathrooms with ChangeNotifier {
  List<Bathroom> _bathrooms = [];
  final geo = Geoflutterfire();
  Position? locationData;

  Future<Bathroom> addBathroom(Bathroom bathroom) async {
    Bathroom? newBathroom;
    CollectionReference bathrooom_collection =
        FirebaseFirestore.instance.collection('bathrooms');
    DocumentReference<Object?> doc;
    try {
      GeoFirePoint myLocation = geo.point(
          latitude: bathroom.location.latitude,
          longitude: bathroom.location.longitude);
      final address = await LocationHelper.generateAddress(
          bathroom.location.latitude, bathroom.location.longitude);
      doc = await bathrooom_collection.add({
        'description': bathroom.description, // John Doe
        'latitude': bathroom.location.latitude, // Stokes and Sons
        'longitude': bathroom.location.longitude,
        'address': address,
        'position': myLocation.data,
        'rating': 0.0
      });

      newBathroom = Bathroom(
          doc.id,
          bathroom.description,
          Location(
              bathroom.location.latitude, bathroom.location.longitude, address),
          [],
          0);
      _bathrooms.add(newBathroom);
    } catch (err) {
      print("something went wrong");
    }

    _bathrooms.add(bathroom);
    notifyListeners();
    return newBathroom!;
  }

  Set<Marker> markers() {
    return {Marker(markerId: MarkerId("de"), position: LatLng(0, 0))};
  }

  void addBathroomRaw(Bathroom bathroom) {
    _bathrooms.add(bathroom);
  }

  Future<void> fetchAndUpdateDistances() async {
    await fetchAndSetBathrooms(withinDistance: 80);

    await updateDistanceFrom();
    notifyListeners();
  }

  Future<Stream<List<DocumentSnapshot<Object?>>>> fetchDistance(
      {double withinDistance = -1.0}) async {
    //_bathrooms.clear();
    GeoFireCollectionRef? geoRef;
    try {
      var bathrooms =
          FirebaseFirestore.instance.collection('bathrooms');
      geoRef = geo.collection(collectionRef: bathrooms);
      await getLocation();
    } catch (err) {
      print("Something went wrong when getting the stream ${err}");
    }
    if (geoRef == null) throw Error();
    return geoRef.within(
        center: GeoFirePoint(locationData!.latitude, locationData!.longitude),
        radius: withinDistance,
        field: "position",
        strictMode: true);
  }

  Future<void> fetchAndSetBathrooms({double withinDistance = -1.0}) async {
    _bathrooms = [];
    List<QueryDocumentSnapshot<Object?>> bathDocs;
    try {
      CollectionReference bathrooms =
          FirebaseFirestore.instance.collection('bathrooms');

      bathDocs = (await bathrooms.get()).docs;

      await Future.forEach(bathDocs, (doc) async {
        if (!doc.exists) return;
        final bathroomData = (doc.data() as Map<String, dynamic>);
        final tempBathroom = Bathroom(
            doc.reference.id,
            bathroomData["description"] as String,
            Location(
                bathroomData["description"],
                bathroomData["longitude"] as double,
                bathroomData["address"] as String),
            [],
            bathroomData["rating"] as double);
        final reviewDocs =
            (await doc.reference.collection("reviews").get()).docs;
        await Future.forEach(reviewDocs, (doc) {
          if (!doc.exists) return;
          final reviewData = doc.data();
          tempBathroom.addReview_raw(Review(
              doc.reference.id,
              reviewData['generalRating'] as double,
              reviewData['review'] as String,
              DateTime.now()));
        });
        _bathrooms.add(tempBathroom);
      });
    } catch (err) {
      print("Something went wrong with error $err");
    }
  }

  Bathroom getBathroomById(String id) {
    
    return _bathrooms.firstWhere((element) => element.id == id);
  }

  List<Bathroom> getBathrooms() {
    return [..._bathrooms];
  }

  Future<bool> getLocation() async {
    try {
      locationData = await GeoLocatorHelper
          .getCurrentLocation(); //.getLocation() //locat.Location()
      // GeoLocatorHelper.getCurrentLocation()
    } catch (err) {
      LoggerHelper.logger.e("Could not get location.");
      return false;
    }
    return true;
  }

  Future<void> updateDistanceFrom() async {
    if (locationData == null) {
      print("Location data is null!!!");
      return;
    }

    if (locationData!.latitude == null || locationData!.longitude == null)
      return;
    _bathrooms.forEach((element) => element.distFromCurrent =
        GeoLocatorHelper.getDistanceBetween(
            locationData!.latitude,
            locationData!.longitude,
            element.location.latitude,
            element.location.longitude));
    print("Got all distances");
  }

  Future<void> fetchReviewsForBathroom(String id) async {
    try {
      CollectionReference reviews_collection =
          FirebaseFirestore.instance.collection('bathrooms/$id/reviews');
      final bathroom = _bathrooms.firstWhere((element) => element.id == id);
      bathroom.emptyReviews();

      final reviews = (await reviews_collection.get()).docs.forEach((doc) {
        if (!doc.exists) return;

        final data = doc.data() as Map<String, dynamic>;
        bathroom.addReview_raw(Review(
            doc.reference.id,
            data['generalRating'] as double,
            data['review'] as String,
            DateTime.parse((data['datePosted'] as String))));
      });
      bathroom.updateRating();
    } catch (e) {
      LoggerHelper.logger.e("Something went wrong with error $e");
    }
  }
}
