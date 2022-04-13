import 'package:datura/ui/constants.dart';
import 'package:datura/ui/page_height.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/grid.dart';
import 'package:datura/util/types.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class WeightEntryPage extends StatefulWidget {
  const WeightEntryPage({ 
    Key? key,
    required this.weightEntry
  }) : super(key: key);

  final IndexedWeightEntry weightEntry;

  @override
  State<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {

  BetterDateTime date = BetterDateTime();
  ValueNotifier<double> weightValueNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    date = widget.weightEntry.date;
    weightValueNotifier.value = widget.weightEntry.weight.toDouble();

    super.initState();
  }
  void selectNewDate() async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context, 
      initialDate: date,
      firstDate: DateTime(2000, 0, 0),
      lastDate: DateTime(2187, 0, 0),
      helpText: "Select new Date!"
    );
    if(selectedDateTime != null) {
      BetterDateTime newDate = BetterDateTime.fromDateTime(selectedDateTime)
        .toDayStart()
        .add(Duration(hours: date.hour, minutes: date.minute, seconds: date.second, milliseconds: date.millisecond, microseconds: date.microsecond));
      setState(() {
        date = newDate;
      });                     
    }
  }
  void selectNewTime() async {
    TimeOfDay? selectedTimeOfDay = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(date));
    if(selectedTimeOfDay != null) {
      BetterDateTime newDate = date.toDayStart().add(Duration(hours: selectedTimeOfDay.hour, minutes: selectedTimeOfDay.minute));
      setState(() {
        date = newDate;
      });
    }
  }
  void goBack() {
    Navigator.of(context).pop();
  }
  void save() {
    Navigator.of(context).pop(widget.weightEntry.copyWith(date: date, weight: weightValueNotifier.value));
  }
  void delete() {
    Navigator.of(context).pop("REMOVE");
  }


  static const double pointSystemConstant = 20.2 / Constants.ratio; // equals 8px
  static const VerticalGrid grid = VerticalGrid(count: 8, gutter: (pointSystemConstant * 2), margin: 0);
  static const HorizontalGrid horizontalGrid = HorizontalGrid(count: 3, gutter: (pointSystemConstant * 2), margin: (pointSystemConstant * 4)); 

  Widget header({ 
    required BetterDateTime date, 
    required void Function() onDateChange, 
    required void Function() onTimeChange 
  }) {
    return Container(
      color: Constants.notQuiteBlack,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SizedBox(
          height: (2 * grid.rowHeight(pageSafeAreaHeight())) + grid.gutter,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              children: [
                Material(
                  color: Constants.transparent,
                  child: InkWell(
                    onTap: onDateChange,
                    child: Text(date.format(padZeros: true), style: GoogleFonts.inter(
                      fontSize: pointSystemConstant * 4,
                      fontWeight: FontWeight.w600,
                      color: Constants.white
                    )),
                  ),
                ),
                const SizedBox(height: pointSystemConstant * 2),
                Material(
                  color: Constants.transparent,
                  child: InkWell(
                    onTap: onTimeChange,
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: pointSystemConstant * 3, color: Constants.white),
                        const SizedBox(width: pointSystemConstant),
                        Text(date.timeOfDay(padZeros: true), style: GoogleFonts.inter(
                          fontSize: pointSystemConstant * 3,
                          fontWeight: FontWeight.w400,
                          color: Constants.white
                        ))
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }
  Widget dateTimeElementWidget({
    required IconData icon,
    required String text,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: pointSystemConstant * 3),
          const SizedBox(width: pointSystemConstant),
          Text(text, style: GoogleFonts.inter(
            fontSize: pointSystemConstant * 3,
            fontWeight: FontWeight.w400
          ))
        ],
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
  Widget dateTimeWidget({
    required BetterDateTime date,
    required void Function() onDateChange,
    required void Function() onTimeChange,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: grid.rowHeight(pageSafeAreaHeight()) + grid.gutter,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio),
        )
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalGrid.margin),
        child: Row(
          children: [
            Expanded(child: dateTimeElementWidget(icon: Icons.event, text: date.format(padZeros: true), onTap: onDateChange)),
            Expanded(child: dateTimeElementWidget(icon: Icons.schedule, text: date.timeOfDay(padZeros: true), onTap: onTimeChange))
          ],
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }
  Widget numberSelectorWidget({
    required ValueNotifier<double> numberSelector
  }) {
    final selectedTextStyle = GoogleFonts.inter(
			fontSize: pointSystemConstant * 4,
			fontWeight: FontWeight.w500,
			color: Constants.black
		);
    final unselectedTextStyle = GoogleFonts.inter(
			fontSize: pointSystemConstant * 3,
			fontWeight: FontWeight.w400,
			color: Constants.black50
		);

    String numberAsText(num number) {
      if(number % 1 != 0) {
        return number.toDouble().toString();
      }
      
      return number.toStringAsFixed(0);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: grid.rowHeight(pageSafeAreaHeight()) + grid.gutter,
      decoration: const BoxDecoration(
        color: Constants.white,
        border: Border(
          top: BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio)
        )
      ),
      child: PageView.builder(
        controller: PageController(initialPage: (numberSelector.value * 10).toInt(), viewportFraction: 0.2),
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          numberSelector.value = index / 10;
        },
        itemCount: 100 * 10,
        itemBuilder: (BuildContext context, index) {
          return Center(
            child: ValueListenableBuilder(
              valueListenable: numberSelector,
              builder: (context, double value, child) {
                return AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: (value * 10) == index ? selectedTextStyle : unselectedTextStyle,
                  child: Text(numberAsText(index / 10))
                );
              }
            )
          );
        },
      ),
    );
  }
  Widget optionWidget({
    required String text, 
    required IconData icon, 
    required void Function() onTap
  }) {
    return SizedBox(
      width: horizontalGrid.columnWidth(MediaQuery.of(context).size.width),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: pointSystemConstant * 3, color: Constants.black),
            const SizedBox(height: pointSystemConstant),
            Text(text, style: GoogleFonts.inter(
              fontSize: pointSystemConstant * 2,
              fontWeight: FontWeight.w400
            ))
          ],
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
  Widget optionsRowWidget({
    required void Function() onBack,
    required void Function() onSave,
    required void Function() onDelete
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: grid.rowHeight(pageSafeAreaHeight()) + grid.gutter,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio),
        )
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalGrid.margin),
        child: Row(
          children: [
            optionWidget(text: "Back", icon: Icons.undo, onTap: onBack),
            optionWidget(text: "Save", icon: Icons.done, onTap: onSave),
            optionWidget(text: "Delete", icon: Icons.delete, onTap: onDelete)
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      body: Column(
        children: [
          header(
            date: date,
            onDateChange: selectNewDate,
            onTimeChange: selectNewTime
          ),
          Column(
            children: [
              dateTimeWidget(
                date: date,
                onDateChange: selectNewDate,
                onTimeChange: selectNewTime
              ),
              numberSelectorWidget(numberSelector: weightValueNotifier),
              optionsRowWidget(
                onBack: goBack,
                onSave: save,
                onDelete: delete
              ),
            ],
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      )
    );
  }

}