import 'package:bathroom_locator/helpers/limits.dart';
import 'package:bathroom_locator/helpers/location_helper.dart';
import 'package:bathroom_locator/helpers/loggerHelper.dart';
import 'package:bathroom_locator/palette.dart';
import 'package:bathroom_locator/screens/bathroomDetail.dart';
import 'package:bathroom_locator/widgets/starRating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../helpers/geoLocatorHelper.dart';
import '../models/bathroom.dart';
import '../providers/bathrooms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/noLocationMessage.dart';
import '../widgets/waitingData.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  bool willDispose = false;
  bool failedLocation = false;
  Stream<List<DocumentSnapshot<Object?>>>? bathStream;

  @override
  void initState() {
    Limits.initialize();

    context.read<Bathrooms>().getLocation().then((value) async {
      if (willDispose) return;
      if (!value) {
        setState(() {
          isLoading = false;
          failedLocation = true;
          ;
        });
      } else if (value) {
        bathStream = await context
            .read<Bathrooms>()
            .fetchDistance(withinDistance: 99999999);
        if (willDispose) return;
        setState(() {
          isLoading = false;
          failedLocation = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    willDispose = true;

    super.dispose();
  }

  //return either a waiting dialog or the list of bathrooms.
  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return WaitingData();
    else if (failedLocation)
      return Center(
        child: const NoLocationMessage(),
      );
    else
      return StreamBuilder<Object>(
          stream: bathStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return WaitingData();
            else if ((snapshot.data as List<DocumentSnapshot<Object?>>).isEmpty)
              return Center(
                child: SizedBox(
                  width: 250,
                  child: Text(
                    "For some reason couldn't find any bathrooms :(",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Palette.DarkBlueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              );
            LoggerHelper.logger.i(
                "Inside the builder for stream. At this point should have data.");
            return ListView(
              // itemBuilder: (ctx, index) => BathroomItem(
              //     bathrooms[index].location.address,
              //     bathrooms[index].rating,
              //     bathrooms[index].id,
              //     bathrooms[index].distFromCurrent),
              // itemCount: snapshot.,
              children: (snapshot.data as List<DocumentSnapshot<Object?>>)
                  .map((data) {
                final dataC = data.data() as Map<String, dynamic>;
                final location = context.read<Bathrooms>().locationData;
                if (location == null) throw Error();

                final distanceFrom = GeoLocatorHelper.getDistanceBetween(
                    location.latitude,
                    location.longitude,
                    dataC['latitude'] as double,
                    dataC['longitude'] as double);
                context.read<Bathrooms>().addBathroomRaw(
                    Bathroom.jsonToBathroom(data.reference.id, dataC));

                return BathroomItem(
                  dataC['address'] as String,
                  dataC['rating'] as double,
                  "${data.reference.id}",
                  distanceFrom,
                );
              }).toList(),
            );
          });
  }
}

class BathroomItem extends StatelessWidget {
  final String id;
  final String address;
  final double rating;
  final double distanceFrom;

  BathroomItem(this.address, this.rating, this.id, this.distanceFrom);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text(
                "${double.parse((distanceFrom / 1609.344).toStringAsFixed(2))} miles away",
                style: TextStyle(
                  color: Palette.DarkBlueColor,
                )),
            subtitle: Text(address,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Palette.BlueTextColor,
                )),
            onTap: () => Navigator.pushNamed(context, BathroomDetail.routeName,
                arguments: id),
            trailing: StarRatingRead(rating),
          ),
        ),
      ],
    );
  }
}
