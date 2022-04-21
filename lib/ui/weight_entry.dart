import 'package:datura/ui/constants.dart';
import 'package:datura/ui/panel.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/grid.dart';
import 'package:datura/util/types.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class WeightEntryWidget extends StatelessWidget {
  const WeightEntryWidget({ 
    Key? key,
    required this.pointSystemConstant,
    required this.grid,
    required this.horizontalGrid,

    required this.weight,
    required this.review,
    this.dateTime,
    this.dateTimeRange,
    this.weightUnit = WeightUnit.kilogram,
    this.average = false,
    this.bottomBorder = false,
    this.onTap,
    this.showMonth = false
  }) : assert((dateTime != null || dateTimeRange != null) && !(dateTime != null && dateTimeRange != null)), super(key: key);

  final double pointSystemConstant;
  final DefinedVerticalGrid grid;
  final DefinedHorizontalGrid horizontalGrid;

  final bool bottomBorder;
  final Review review;
  final num weight;
  final WeightUnit weightUnit;
  final bool average;
  final BetterDateTime? dateTime;
  final BetterDateTimeRange? dateTimeRange;
  final void Function()? onTap;
  final bool showMonth;

  String weightAsText(num weight) {
    if(weight % 1 != 0) {
      return weight.toDouble().toString();
    }
    
    return weight.toStringAsFixed(0);
  }

  Widget dateTextWidget({
    BetterDateTime? dateTime,
    BetterDateTimeRange? dateTimeRange,
    bool month = false,
  }) {
    assert((dateTime != null || dateTimeRange != null) && !(dateTime != null && dateTimeRange != null));

    String dateText(BetterDateTime dateTime) {
      if(dateTime.isToday()) return "Today";
      if(dateTime.wasYesterday()) return "Yesterday";

      if(month) return dateTime.format(padZeros: true, year: false, month: true, day: true);
      return dateTime.day.toString() + "th";
    }

    String text = dateTime != null ? dateText(dateTime) : dateTimeRange!.format(forHumans: true);

    return SizedBox(
      width: horizontalGrid.definedColumnWidth,
      child: Text(text, style: GoogleFonts.inter(
        fontSize: pointSystemConstant * 2,
        fontWeight: FontWeight.w400
      )),
    );
  }
  Widget reviewTextWidget(Review review) {
    Color color = review == Review.ok ? Constants.blue : (review == Review.good ? Constants.green : Constants.red);

    return SizedBox(
      width: horizontalGrid.definedColumnWidth, // just a random value,
      child: Text(review.name, textAlign: TextAlign.right, style: GoogleFonts.inter(
        fontSize: pointSystemConstant * 2,
        fontWeight: FontWeight.w400,
        color: color
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      width: horizontalGrid.space,
      height: grid.definedRowHeight + grid.gutter,
      bottomBorder: bottomBorder,
      pointSystemConstant: pointSystemConstant,
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
                  dateTime: dateTime,
                  dateTimeRange: dateTimeRange,
                  month: showMonth
                ),
                average ? Column(
                  children: [
                    Text("avg.", style: GoogleFonts.inter(
                      fontSize: pointSystemConstant * 2,
                      fontWeight: FontWeight.w400,
                      color: Constants.black50
                    )),
                    SizedBox(height: pointSystemConstant),
                    Text(weightAsText(weight) + weightUnit.name, style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: pointSystemConstant * 3
                    )),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ) : Text(weightAsText(weight) + weightUnit.name, style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: pointSystemConstant * 3
                )),
                reviewTextWidget(review)
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
        ),
      ),
    );
  }
}