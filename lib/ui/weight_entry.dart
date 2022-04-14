import 'package:datura/pages/page.dart';
import 'package:datura/ui/constants.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/types.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class WeightEntryWidget extends StatelessWidget {
  const WeightEntryWidget({ 
    Key? key,
    required this.height,
    required this.weight,
    required this.review,
    this.dateTime,
    this.dateTimeRange,
    this.weightUnit = WeightUnit.kilogram,
    this.average = false,
    this.bottomBorder = false,
    this.onTap
  }) : assert((dateTime != null || dateTimeRange != null) && !(dateTime != null && dateTimeRange != null)), super(key: key);

  final num height;
  final bool bottomBorder;
  final Review review;
  final num weight;
  final WeightUnit weightUnit;
  final bool average;
  final BetterDateTime? dateTime;
  final BetterDateTimeRange? dateTimeRange;
  final void Function()? onTap;

  String weightAsText(num weight) {
    if(weight % 1 != 0) {
      return weight.toDouble().toString();
    }
    
    return weight.toStringAsFixed(0);
  }

  Widget dateTextWidget({
    required BuildContext context,
    BetterDateTime? dateTime,
    BetterDateTimeRange? dateTimeRange
  }) {
    assert((dateTime != null || dateTimeRange != null) && !(dateTime != null && dateTimeRange != null));

    String text = dateTime != null ? dateTime.day.toString() + "th" : dateTimeRange!.format(forHumans: true);

    return SizedBox(
      width: horizontalGrid.columnWidth(MediaQuery.of(context).size.width),
      child: Text(text, style: GoogleFonts.inter(
        fontSize: pointSystemConstant * 2,
        fontWeight: FontWeight.w400
      )),
    );
  }
  Widget reviewTextWidget(BuildContext context, Review review) {
    Color color = review == Review.ok ? Constants.blue : (review == Review.good ? Constants.green : Constants.red);

    return SizedBox(
      width: horizontalGrid.columnWidth(MediaQuery.of(context).size.width), // just a random value,
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
            onTap!();
          }
        },
        child: Material(
          color: Constants.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalGrid.margin),
            child: Row(
              children: [
                dateTextWidget(
                  context: context,
                  dateTime: dateTime,
                  dateTimeRange: dateTimeRange
                ),
                Text(weightAsText(weight) + weightUnit.name, style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: pointSystemConstant * 3
                )),
                reviewTextWidget(context, review)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
        ),
      ),
    );
  }
}