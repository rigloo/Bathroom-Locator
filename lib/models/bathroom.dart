import 'package:bathroom_locator/helpers/loggerHelper.dart';
import 'package:bathroom_locator/models/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bathroom_locator/models/location.dart';

class Bathroom {
  Bathroom(
      this.id, this.description, this.location, this._reviews, this.rating);
  final String id;
  final String description;
  final Location location;
  final List<Review> _reviews;
  double rating;
  var distFromCurrent = -1.0;
  // double get rating {
  //   double sum = 0;
  //   if (_reviews.length == 0) return -1;
  //   _reviews.forEach((element) {
  //     sum += element.generalRating;
  //   });
  //   return sum / _reviews.length; // reviews.length;
  // }
  void emptyReviews() {
    _reviews.clear();
  }

  List<Review> get reviews {
    return [..._reviews];
  }

  Future<void> addReview(Review review) async {
    CollectionReference reviews_collection =
        FirebaseFirestore.instance.collection('bathrooms/$id/reviews');
    DocumentReference<Object?> doc;
    try {
      doc = await reviews_collection.add({
        'generalRating': review.generalRating, // John Doe
        'datePosted': review.datePosted.toIso8601String(), // Stokes and Sons
        'review': review.review // 42
      });

      _reviews.add(Review(
          doc.id, review.generalRating, review.review, review.datePosted));
    } catch (err) {
      LoggerHelper.logger.e("Somethinh went wrong with error $err");
    }
  }

  static Bathroom jsonToBathroom(String id, Map<String, dynamic> data) {
    return Bathroom(
        id,
        data['description'] as String,
        Location(data['latitude'] as double, data['longitude'] as double,
            data['address'] as String),
        [],
        (data['rating'] as double));
  }

//add review that doesnt add to cloud, needed when initially fetching and setting initial bathroom
  void addReview_raw(Review review) {
    _reviews.add(review);
  }

  Future<void> updateRating() async {
    var total = 0.0;

    if (_reviews.isEmpty) return;

    _reviews.forEach((review) {
      total += review.generalRating;
    });

    rating = total / _reviews.length;

    CollectionReference bathroom =
        FirebaseFirestore.instance.collection('bathrooms');

    await bathroom
        .doc('$id')
        .update({'rating': rating})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}
