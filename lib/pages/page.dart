import 'package:datura/main.dart';
import 'package:datura/pages/options_page.dart';
import 'package:datura/pages/weight_entry_page.dart';
import 'package:datura/ui/add_button.dart';
import 'package:datura/ui/constants.dart';
import 'package:datura/ui/page_height.dart';
import 'package:datura/ui/weight_entry.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/faker.dart';
import 'package:datura/util/firebase.dart' as firebase;
import 'package:datura/util/grid.dart';
import 'package:datura/util/models.dart';
import 'package:datura/util/types.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class MainPageScreen extends StatefulWidget {

  const MainPageScreen({ 
    Key? key,
    required this.initialTimeRange,
    this.onNewTimeRange
  }) : super(key: key);

  final BetterDateTimeRange initialTimeRange;
  final void Function(BetterDateTimeRange)? onNewTimeRange;

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();

}

const pointSystemConstant = 20.2 / Constants.ratio; // equals 8px
const VerticalGrid grid = VerticalGrid(count: 8, gutter: (pointSystemConstant * 2), margin: 0);
const HorizontalGrid horizontalGrid = HorizontalGrid(count: 3, gutter: (pointSystemConstant * 2), margin: (pointSystemConstant * 4));

class _MainPageScreenState extends State<MainPageScreen> {

  // WeightEntriesModel get weightEntriesModel => AppState.of(context).model;

  BetterDateTimeRange timeRange = BetterDateTimeRange.today();
  WeightEntriesModelShadow modelShadow = WeightEntriesModelShadow();

  IndexedWeightEntry? lastDeletedWeightEntry;

  void addWeightEntry(double weight) {
    AppState.of(context).model.addUnindexedWeightEntry(Faker.weight().copyWith(date: BetterDateTime(), weight: weight));

    firebase.logAddWeightEntryEvent();

    // update UI
    updateTimeRange(timeRange);
  }
  void removeWeightEntry(WeightEntryModel weightEntryModel) {
    AppState.of(context).model.removeWeightEntry(weightEntryModel);

    // update UI
    updateTimeRange(timeRange);
  }
  void weightEntryOnTap(WeightEntryModel weightEntryModel) async {
    dynamic updatedWeightEntry = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => WeightEntryPage(weightEntry: weightEntryModel.value)));

    if(updatedWeightEntry == "REMOVE") {
      // entry should be removed
      removeWeightEntry(weightEntryModel);
      lastDeletedWeightEntry = weightEntryModel.value;

      showDeleteRedoSnackbar();

      // update UI
      updateTimeRange(timeRange);
    } else if(updatedWeightEntry is WeightEntry) {
      // entry should be updated
      weightEntryModel.set(updatedWeightEntry);
      
      // update UI
      updateTimeRange(timeRange);
    }
  }
  void restoreLastDeletedWeightEntry() {
    if(lastDeletedWeightEntry != null) {
      AppState.of(context).model.addWeightEntry(lastDeletedWeightEntry!);
      updateTimeRange(timeRange);
    }
  }
  void showDeleteRedoSnackbar() {
    final snackbar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: horizontalGrid.margin),
      duration: const Duration(seconds: 5),
      content: SizedBox(
        height: grid.rowHeight(pageSafeAreaHeight()),
        child: Row(
          children: [
            Text("Deleted weight Entry!", style: GoogleFonts.inter(
              fontSize: pointSystemConstant * 2.5,
              color: Constants.white,
              fontWeight: FontWeight.w400
            )),
            Material(
              color: Constants.transparent,
              child: InkWell(
                onTap: () {
                  restoreLastDeletedWeightEntry();
                  ScaffoldMessenger.of(context).clearSnackBars();
                },
                child: Padding(
                  padding: const EdgeInsets.all(pointSystemConstant * 2),
                  child: Text("Undo", style: GoogleFonts.inter(
                    fontSize: pointSystemConstant * 2.5,
                    color: Constants.white,
                    fontWeight: FontWeight.w500
                  )),
                ),
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
        ),
      ),
      backgroundColor: Constants.notQuiteBlack,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  void initState() {
    super.initState();

    timeRange = widget.initialTimeRange;

    Future.delayed(const Duration(seconds: 0)).then((dynamic) {

      // updateTimeRange(timeRange);

    });

  }
  @override
  void dispose() {
    super.dispose();

    modelShadow.dispose();
  }
  
  void updateTimeRange(BetterDateTimeRange betterDateTimeRange) async {
    final BetterDateTimeRange newTimeRange = BetterDateTimeRange(start: betterDateTimeRange.start, end: betterDateTimeRange.end.toDayEnd());

    // modelShadow.disposeListeners();
    // WeightEntriesModelShadow newModelShadow = weightEntriesModel.shadow(newTimeRange);

    if(widget.onNewTimeRange != null) {
      widget.onNewTimeRange!(newTimeRange);
    }

    setState(() {
      timeRange = newTimeRange;
      // modelShadow = newModelShadow;
    });
  }

  Widget scrollableSectionWidget() {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: HeaderDelegate(
            pageTopPadding: pageTopPadding(),
            onSelect: (DateTimeRange selectedTimeRange) {
              updateTimeRange(BetterDateTimeRange.fromDateTimeRange(selectedTimeRange));
            }, 
            pageHeight: pageSafeAreaHeight(),
            timeRange: timeRange
          ),
        ),
        ValueListenableBuilder(
          valueListenable: modelShadow,
          builder: (context, List<WeightEntryModel> weightEntries, widget) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return WeightEntryWidget(
                    height: grid.rowHeight(pageSafeAreaHeight()) + grid.gutter,
                    weightEntryModel: weightEntries[index],
                    bottomBorder: weightEntries.length == index + 1,
                    onTap: weightEntryOnTap
                  );
                },
                childCount: weightEntries.length
              ),
            );
          }
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // create new shadow based on new timeRange
    modelShadow = AppState.of(context).model.createShadow(timeRange);

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: scrollableSectionWidget(),
          ),
          AddButton(
            elementHeight: grid.rowHeight(pageSafeAreaHeight()) + grid.gutter,
            pointSystemConstant: pointSystemConstant,
            onSaveNewEntry: (double weight) {
              addWeightEntry(weight);
            },
            weightSelectorInitialValue: () {
              if(AppState.of(context).model.value.isEmpty) return 50;

              List<WeightEntryModel> weightEntries = AppState.of(context).model.value;
              double sum = (weightEntries.fold<num>(0, (acc, entry) => acc + entry.value.weight.toDouble())).toDouble();

              return ((sum / weightEntries.length).toDouble() * 10).round() / 10;
            },
          )
        ],
      ),
    );
  }

}

class HeaderDelegate extends SliverPersistentHeaderDelegate {

  HeaderDelegate({ 
    required this.pageTopPadding,
    required this.pageHeight,
    required this.timeRange,
    required this.onSelect,
  });

  final double pageTopPadding;
  final double pageHeight;
  final BetterDateTimeRange timeRange;
  final void Function(DateTimeRange selectedRange) onSelect;

  void openOptionsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const OptionsPage()));
  } 

  String timeRangeText(BetterDateTimeRange range) {
    // TODO
    if(timeRange.start.month == timeRange.end.month && timeRange.start.year == timeRange.end.year) {
      // timeRange spans over the same month
      return BetterDateTime.fromDateTime(range.start).monthName;  
    } else {
      return BetterDateTime.fromDateTime(range.start).monthName;
    }
  }

  void pickDate(BuildContext context, BetterDateTime initialDate, bool isFirstDate) async {
    DateTime? selectedDate = await showDatePicker(
      helpText: "Select the ${isFirstDate ? "first" : "second"} date!",
      context: context,
      firstDate: DateTime(2000, 0, 0),
      lastDate: DateTime(2187, 0, 0),
      initialDate: initialDate,
    );
    if(selectedDate != null) {
      onSelect(BetterDateTimeRange(start: isFirstDate ? BetterDateTime.fromDateTime(selectedDate) : BetterDateTime.fromDateTime(timeRange.start), end: !isFirstDate ? BetterDateTime.fromDateTime(selectedDate) : BetterDateTime.fromDateTime(timeRange.end)));
    }
  }


  static const double borderWidth = 2.52 / Constants.ratio; 

  Widget dateTextWidget({ required context, required BetterDateTime date, required TextStyle style, required bool isFirstDate }) {
    return Material(
      color: Constants.transparent,
      child: InkWell(
        onTap: () {
          pickDate(context, date, isFirstDate);
        },
        child: Text(date.format(padZeros: true), style: style),
      ),
    );   
  }
  Widget headerWidget(BuildContext context, double shrinkOffset) {
    final double headerWidth = MediaQuery.of(context).size.width;
    double spacing = pointSystemConstant * 2;
  
    const double titleFontSize = pointSystemConstant * 4;
    const double subtitleFontSize = pointSystemConstant * 2;
    final subtitleTextStyle = GoogleFonts.inter(fontSize: subtitleFontSize, fontWeight: FontWeight.w400, color: Constants.white);

    const double dateTextWidgetsSpacing = pointSystemConstant;

    return Center(
      child: SizedBox(
        width: headerWidth,
        child: Column(
          children: [
            Text(timeRangeText(timeRange), style: GoogleFonts.inter(
              color: Constants.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600
            )),
            SizedBox(height: spacing), 
            Row(
              children: [
                dateTextWidget(
                  isFirstDate: true,
                  context: context,
                  date: BetterDateTime.fromDateTime(timeRange.start),
                  style: subtitleTextStyle
                ),
                const SizedBox(width: dateTextWidgetsSpacing),
                Text("-", style: subtitleTextStyle),
                const SizedBox(width: dateTextWidgetsSpacing),
                dateTextWidget(
                  isFirstDate: false,
                  context: context,
                  date: BetterDateTime.fromDateTime(timeRange.end),
                  style: subtitleTextStyle
                ),
              ],
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
  Widget optionsButtonWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: (2 * pointSystemConstant), top: (2 * pointSystemConstant)),
      child: Material(
        color: Constants.transparent,
        child: InkWell(
          onTap: () {
            openOptionsPage(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(pointSystemConstant * 3),
            child: Icon(Icons.more_vert, size: pointSystemConstant * 4, color: Constants.white),
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Constants.notQuiteBlack,
      child: Padding(
        padding: EdgeInsets.only(top: pageTopPadding),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: optionsButtonWidget(context),
            ),
            Column(
              children: [
                Expanded(child: headerWidget(context, shrinkOffset)),
              ],
            ),
          ]
        ),
      ),
    );
  }

  @override
  double get maxExtent => ((grid.rowHeight(pageHeight) * 2) + grid.gutter + pageTopPadding);

  @override
  double get minExtent => (grid.rowHeight(pageHeight) * 2) + grid.gutter + pageTopPadding;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}


class MainPage extends StatefulWidget {

  const MainPage({ Key? key }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();

}

class _MainPageState extends State<MainPage> {

  List<BetterDateTimeRange> timeRanges = [];

  BetterDateTime shiftDate(BetterDateTime date, int shift) {
    if(shift > 0) {
      return shiftDate(date.nextMonth(), shift - 1);
    } else if(shift < 0) {
      return shiftDate(date.previousMonth(), shift + 1);
    } else {
      return date;
    }
  }

  @override
  void initState() {
    super.initState();

    for(var i = 0; i < 12; i ++) {
      BetterDateTime newStart = shiftDate(BetterDateTimeRange.thisMonth().start, i - (BetterDateTime().month - 1)).toMonthStart();
      BetterDateTime newEnd = shiftDate(BetterDateTimeRange.thisMonth().end, i - (BetterDateTime().month - 1)).toMonthEnd();

      BetterDateTimeRange timeRange = BetterDateTimeRange(start: newStart, end: newEnd);
      timeRanges.add(timeRange);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      body: PageView.builder(
        controller: PageController(initialPage: BetterDateTime().month - 1),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, _index) {

          if(_index >= timeRanges.length) {
            BetterDateTime newStart = shiftDate(BetterDateTimeRange.thisMonth().start, _index - (BetterDateTime().month - 1)).toMonthStart();
            BetterDateTime newEnd = shiftDate(BetterDateTimeRange.thisMonth().end, _index - (BetterDateTime().month - 1)).toMonthEnd();
            timeRanges.add(BetterDateTimeRange(start: newStart, end: newEnd));            
          }

          // BetterDateTime newStart = shiftDate(BetterDateTimeRange.thisMonth().start, index).toMonthStart();
          // BetterDateTime newEnd = shiftDate(BetterDateTimeRange.thisMonth().end, index).toMonthEnd();

          BetterDateTimeRange timeRange = timeRanges[_index]; // BetterDateTimeRange(start: newStart, end: newEnd);

          return MainPageScreen(
            initialTimeRange: timeRange,
            onNewTimeRange: (BetterDateTimeRange newTimeRange) {
              timeRanges[_index] = newTimeRange;
            }
          );
        },
      )
    );
  }

}