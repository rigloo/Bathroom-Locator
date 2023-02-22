import 'package:bathroom_locator/helpers/loggerHelper.dart';
import 'package:bathroom_locator/helpers/mapLauncherHelper.dart';
import 'package:bathroom_locator/models/review.dart';
import 'package:bathroom_locator/palette.dart';
import 'package:bathroom_locator/providers/bathrooms.dart';
import 'package:bathroom_locator/widgets/starRating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/limits.dart';
import '../models/bathroom.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class BathroomDetail extends StatefulWidget {
  static String routeName = "/BathroomDetail";

  @override
  State<BathroomDetail> createState() => _BathroomDetailState();
}

class _BathroomDetailState extends State<BathroomDetail> {
  bool willDispose = false;
  bool isLoading = true;
  bool loadedDepend = false;
  void startAddNewTransaction(BuildContext context, Bathroom bathroom) {
    final snackBar = SnackBar(

        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          color: Theme.of(context).primaryColor,
          title: 'Error adding review!',
          message:
              'Oops.. You\'ve reached the limit for today of adding reviews (3). Try again tomorrow.',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ));
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: NewReview(bathroom),
        ));
      },
    ).then((value) async {
      await bathroom.updateRating();
      if (value == null)
        ;
      else if (!value) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (willDispose) return;
      setState(
        () {},
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    willDispose = true;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (loadedDepend)
      ;
    else {
      LoggerHelper.logger.i("About to fetch Reviews for this Bathroom");
      context
          .read<Bathrooms>()
          .fetchReviewsForBathroom(
              (ModalRoute.of(context)!.settings.arguments as String))
          .then((value) {
        setState(() {
          isLoading = false;
          loadedDepend = true;
        });
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bathroomId = ModalRoute.of(context)!.settings.arguments as String;
    final Bathroom bathroom =
        context.read<Bathrooms>().getBathroomById(bathroomId);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.BlueTextColor,
        foregroundColor: Palette.DarkBlueColor,
        child: Icon(Icons.add),
        onPressed: () {
          startAddNewTransaction(context, bathroom);
        },
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          "Bathroom Detail",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(
              child: Text("Average Rating",
                  style: TextStyle(
                      color: Palette.DarkBlueColor,
                      fontWeight: FontWeight.bold))),
          Center(child: StarRatingRead(bathroom.rating)),
          SizedBox(
            height: 20,
          ),
          Text("Description",
              style: TextStyle(
                  color: Color.fromRGBO(43, 52, 103, 1),
                  fontWeight: FontWeight.bold)),
          Text(bathroom.description,
              style: TextStyle(
                color: Color.fromRGBO(43, 52, 103, 1),
              )),
          ElevatedButton.icon(
            icon: Icon(Icons.map_outlined),
            label: Text("Get Directions"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              MapLauncherHelper.showMap(bathroom.location.latitude,
                  bathroom.location.longitude, bathroom.location.address);
            },
          ),
          SizedBox(
            height: 20,
          ),
          Text("Reviews",
              style: TextStyle(
                  color: Color.fromRGBO(43, 52, 103, 1),
                  fontWeight: FontWeight.bold)),
          Flexible(
            child: isLoading ? WaitingReviews() : ReviewList(bathroom),
          )
        ]),
      ),
    );
  }
}

class ReviewList extends StatelessWidget {
  final Bathroom bathroom;
  ReviewList(this.bathroom);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Palette.DarkBlueColor, width: 3)),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: bathroom.reviews.isEmpty
            ? Center(
                child: Text(
                  "There aren't any reviews for this bathroom yet :(",
                  style: TextStyle(color: Palette.DarkBlueColor),
                ),
              )
            : ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      bathroom.reviews[index].review,
                    ),
                    subtitle: Text(DateFormat.yMMMMd()
                        .format(bathroom.reviews[index].datePosted)),
                    trailing: StarRatingRead(
                        bathroom.reviews[index].generalRating.toDouble()),
                  );
                },
                itemCount: bathroom.reviews.length,
              ),
      ),
    );
  }
}

class NewReview extends StatefulWidget {
  final Bathroom bathroom;

  NewReview(this.bathroom);
  @override
  State<NewReview> createState() => _NewReviewState();
}

class _NewReviewState extends State<NewReview> {
  final _form = GlobalKey<FormState>();
  var isLoading = false;
  bool willDispose = false;

  Review newReview = Review("-1", -1, "", DateTime.now());

  @override
  void dispose() {
    willDispose = true;
    super.dispose();
  }

  void updateRating(double value) {
    newReview = Review("-1", value, newReview.review, newReview.datePosted);
  }

  void saveForm() async {
    bool? isValid = _form.currentState?.validate();
    if (!isValid! || newReview.generalRating == -1) return;

    _form.currentState?.save();

    newReview = Review(DateTime.now().toString(), newReview.generalRating,
        newReview.review, newReview.datePosted);

    setState(() {
      isLoading = true;
    });

    if (!(await Limits.canWriteReviews())) {
      if (!willDispose) setState(() => isLoading = false);
      Navigator.of(context).pop(false);
      return;
    }
    await widget.bathroom.addReview(newReview);
    if (!willDispose)
      setState(() {
        isLoading = false;
      });
    Navigator.of(context).pop(true);
    print("JUST POPPED OFF WITH VALUE for is LOADING");
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
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    Text("Add Review",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Palette.DarkBlueColor)),
                    SizedBox(
                      height: 10,
                    ),
                    StarRatingEdit(0.0, updateRating),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      maxLines: 2,
                      maxLength: 89,
                      style: TextStyle(color: Palette.DarkBlueColor),
                      decoration: InputDecoration(
                          hoverColor: Palette.DarkBlueColor,
                          focusColor: Palette.DarkBlueColor,
                          fillColor: Palette.DarkBlueColor,
                          labelText: 'Short Review',
                          hintText: "ex. \"Stinky! Avoid at all costs!\""),
                      textInputAction: TextInputAction.next,
                      onSaved: (newValue) => newReview = Review(
                          "-1",
                          newReview.generalRating,
                          newValue!,
                          newReview.datePosted),
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Please type something for a Short Review";
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () => saveForm(),
                      child: Text(
                        "Save Review",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class WaitingReviews extends StatelessWidget {
  const WaitingReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("Loading Reviews..."),
          CircularProgressIndicator(backgroundColor: Palette.BlueTextColor),
        ],
      ),
    );
  }
}
