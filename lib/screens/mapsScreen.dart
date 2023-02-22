import 'package:bathroom_locator/helpers/geoLocatorHelper.dart';
import 'package:bathroom_locator/helpers/limits.dart';
import 'package:bathroom_locator/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../helpers/loggerHelper.dart';
import '../models/bathroom.dart';
import '../models/location.dart';
import '../providers/bathrooms.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/noLocationMessage.dart';
import '../widgets/waitingData.dart';
import 'bathroomDetail.dart';

class MapsScreen extends StatefulWidget {
  Location location;
  bool isSelecting;

  MapsScreen(
      {this.location = const Location(37.422, -122, ""),
      this.isSelecting = true});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  bool willDispose = false;
  Position? pos;
  bool isLoading = true;
  Stream<List<DocumentSnapshot<Object?>>>? bathStream;
  bool failedLocation = false;

  Future<String> addNewBathroom(String description) async {
    final canWrite = await Limits.canWriteBathrooms();
    if (canWrite) {
      final bathroom = await context.read<Bathrooms>().addBathroom(Bathroom(
          "-1",
          description,
          Location(_pickedLocation!.latitude, _pickedLocation!.longitude, ""),
          [],
          0));
      return bathroom.id;
    } else {
      return "-1";
    }
  }

  void startTransaction(BuildContext context) {
    final snackBar = SnackBar(

        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          color: Theme.of(context).primaryColor,
          title: 'Error adding bathroom!',
          message:
              'Oops.. You\'ve reached the limit for today of adding bathrooms (3). Try again tomorrow.',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ));
    var succeeded = true;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: NewBathroom(addNewBathroom),
        ));
      },
    ).then((value) {
      if (value == null)
        ;
      else if (!value) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(
        () => null,
      );
    });
  }

  @override
  void initState() {
    context.read<Bathrooms>().getLocation().then((value) async {
      if (willDispose) return;
      if (!value) {
        setState(() {
          isLoading = false;
          failedLocation = true;
          ;
        });
      } else if (value) {
        pos = context.read<Bathrooms>().locationData;
        bathStream =
            await context.read<Bathrooms>().fetchDistance(withinDistance: 99999999);
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
    LoggerHelper.logger.i("About to dispose MAPSCREEN");
    willDispose = true;

    super.dispose();
  }

  LatLng? _pickedLocation;

  void _selectLocation(LatLng position) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _pickedLocation = position;
    });

    final snackBar = SnackBar(

        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Stack(alignment: Alignment.bottomCenter, children: [
          AwesomeSnackbarContent(
            color: Palette.DarkBlueColor,
            title: 'Bathroom Selected!',
            message: 'Would you like to add a Bathroom in this location?',

            /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
            contentType: ContentType.help,
          ),
          OutlinedButton(
            onPressed: () {
              print("Pressed Yes");
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              startTransaction(context);
            },
            child: Text(
              "YES",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold),
            ),
          )
        ]));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return WaitingData();
    else if (failedLocation)
      return Center(
        child: const NoLocationMessage(),
      );
    else {
      return StreamBuilder<Object>(
          stream: bathStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return WaitingData();
            LoggerHelper.logger.i(
                "Inside the builder for stream. At this point should have data.");
            Set<Marker> markers =
                (snapshot.data as List<DocumentSnapshot<Object?>>).map((data) {
              LoggerHelper.logger.i("Received marker data as so $data");
              return Marker(
                  onTap: () {
                    Navigator.pushNamed(context, BathroomDetail.routeName,
                        arguments: data.id);
                  },
                  markerId: MarkerId(data.id),
                  position: LatLng(
                    data['latitude'] as double,
                    data['longitude'] as double,
                  ));
            }).toSet();
            if (_pickedLocation != null) {
              markers.add(Marker(
                  markerId: MarkerId("myLoc"),
                  position: LatLng(
                      _pickedLocation!.latitude, _pickedLocation!.longitude)));
            }
            return GoogleMap(
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                myLocationEnabled: true,
                onTap: _selectLocation,
                initialCameraPosition: CameraPosition(
                  target: LatLng(pos!.latitude, pos!.longitude),
                  zoom: 16,
                ),
                markers: markers);
          });
    }
  }
}

class NewBathroom extends StatefulWidget {
  Function addNew;
  NewBathroom(this.addNew);

  @override
  State<NewBathroom> createState() => _NewBathroomState();
}

class _NewBathroomState extends State<NewBathroom> {
  final titleController = TextEditingController();
  bool isLoading = false;

  void onSave() async {
    if (titleController.text.isEmpty) {
      print("Invalid Input!");
      return;
    }
    setState(() {
      isLoading = true;
    });
    final id = (await widget.addNew(titleController.text)) as String;
    setState(() {
      isLoading = false;
    });

    if (id == "-1")
      Navigator.of(context).pop(false);
    else {
      Navigator.of(context).pop(true);
      Navigator.pushNamed(context, BathroomDetail.routeName, arguments: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            width: double.infinity,
            height: 200,
          )
        : Card(
            child: Padding(
              child: Column(
                children: [
                  Text(
                    "Input a Short Description that might help others how to find it",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Palette.DarkBlueColor,
                        fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    maxLength: 44,
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                        hoverColor: Palette.DarkBlueColor,
                        focusColor: Palette.DarkBlueColor,
                        fillColor: Palette.DarkBlueColor,
                        labelText: '',
                        hintText: "ex. \"Inside building GMC 2nd floor\""),
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onSave();
                    },
                    child: Text(
                      "Add Bathroom",
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                  )
                ],
              ),
              padding: EdgeInsets.all(10),
            ),
          );
  }
}
