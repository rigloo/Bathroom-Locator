import 'package:bathroom_locator/helpers/DBHelper.dart';
import 'package:bathroom_locator/helpers/loggerHelper.dart';
import 'package:intl/intl.dart';

const BATH_LIMIT = 3;
const REVIEW_LIMIT = 3;

class Limits {
  static bool? isInitialized;
  static int? bathroomWrites;
  static int? reviewWrites;
  static final today = DateFormat.yMMMMd().format(DateTime.now());

  static Future<bool> initialize() async {
    //delete all documents where the date is not the current date
    try {
      await DBHelper.deleteBefore('limits', today);
      final data = await DBHelper.fetchDataDate('limits', today);

      if (data.isEmpty) {
        await DBHelper.insert("limits", {
          'id': DateTime.now().toString(),
          'date': today,
          'bathWrites': 0,
          'reviewWrites': 0
        });
        bathroomWrites = 0;
        reviewWrites = 0;
        isInitialized = true;
        return true;
      }

      bathroomWrites = data[0]['bathWrites'] as int;
      reviewWrites = data[0]['reviewWrites'] as int;
    } catch (e) {
      LoggerHelper.logger.e(
          "Something went wrong when initializing Limits data with error: $e");
    }

    LoggerHelper.logger.i(
        "Initializing limits to with data bathroomWrites = $bathroomWrites and reviewWrites = $reviewWrites");

    return true;
  }

  static Future<bool> canWriteBathrooms() async {
    LoggerHelper.logger.i(
        "Will write a bathroom. so far have written  $bathroomWrites today.");
    if (bathroomWrites! >= BATH_LIMIT) return false;
    bathroomWrites = bathroomWrites! + 1;

    await DBHelper.updateBathroomWrites('limits', today, bathroomWrites!);
    return true;
  }

  static Future<bool> canWriteReviews() async {
    LoggerHelper.logger
        .i("Will write a review. so far have written  $reviewWrites today.");
    if (reviewWrites! >= REVIEW_LIMIT) return false;
    reviewWrites = reviewWrites! + 1;

    await DBHelper.updateReviewWrites('limits', today, reviewWrites!);
    return true;
  }
}
