import 'package:datura/pages/page2.dart';
import 'package:datura/ui/constants.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/faker.dart';
import 'package:datura/util/models.dart';
import 'package:datura/util/rand.dart';
import 'package:datura/util/types.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class WeightEntryWidget extends StatelessWidget {
  const WeightEntryWidget({ 
    Key? key,
    required this.height,
    required this.weightEntryModel,
    this.bottomBorder = false,
    this.onTap
  }) : super(key: key);

  final num height;
  final bool bottomBorder;
  final WeightEntryModel weightEntryModel;
  final void Function(WeightEntryModel weightEntryModel)? onTap;

  String weightAsText(num weight) {
    if(weight % 1 != 0) {
      return weight.toDouble().toString();
    }
    
    return weight.toStringAsFixed(0);
  }

  // TODO: allow also to pass a timeRange
  Widget dateTextWidget(BetterDateTime date) {
    return SizedBox(
      width: pointSystemConstant * 10, // just a random value
      child: Text(BetterDateTime.fromDateTime(date).format()/* date.day.toString() + "th" */, style: GoogleFonts.inter(
        fontSize: pointSystemConstant * 2,
        fontWeight: FontWeight.w400
      )),
    );
  }
  Widget reviewTextWidget(Review review) {
    Color color = review == Review.ok ? Constants.blue : (review == Review.good ? Constants.green : Constants.red);

    return SizedBox(
      width: pointSystemConstant * 10, // just a random value
      child: Text(review.name, textAlign: TextAlign.right, style: GoogleFonts.inter(
        fontSize: pointSystemConstant * 2,
        fontWeight: FontWeight.w400,
        color: color
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const borderWidth = 2.52 / Constants.ratio;

    return Container(
      width: width,
      height: height.toDouble(),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: Constants.borderGrey, width: borderWidth),
          bottom: bottomBorder ? const BorderSide(color: Constants.borderGrey, width: borderWidth) : BorderSide.none 
        )
      ),
      child: InkWell(
        onTap: () {
          if(onTap != null) {
            onTap!(weightEntryModel);
          }
        },
        child: Material(
          color: Constants.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: pointSystemConstant * 4),
            child: Row(
              children: [
                dateTextWidget(weightEntryModel.value.date),
                Text(weightAsText(weightEntryModel.value.weight) + weightEntryModel.value.weightUnit.name, style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: pointSystemConstant * 3
                )),
                reviewTextWidget(weightEntryModel.value.review != null ? weightEntryModel.value.review! : Review.ok)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
        ),
      ),
    );
  }
}