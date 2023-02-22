import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRatingRead extends StatelessWidget {
  @override
  final double rating;
  StarRatingRead(this.rating);
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: FittedBox(
        fit: BoxFit.cover,
        child: RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (value) => null,
          ignoreGestures: true,
        ),
      ),
    );
    ;
  }
}

class StarRatingEdit extends StatelessWidget {
  @override
  final double rating;
  final Function updateRating;
  StarRatingEdit(this.rating, this.updateRating);
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: FittedBox(
        fit: BoxFit.cover,
        child: RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (value) => updateRating(value),
          ignoreGestures: false,
        ),
      ),
    );
    ;
  }
}
