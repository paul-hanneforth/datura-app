import 'package:datura/main.dart';
import 'package:datura/ui/constants.dart';
import 'package:datura/ui/option.dart';
import 'package:datura/ui/page_height.dart';
import 'package:datura/util/grid.dart';
import 'package:datura/util/mode.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class OptionsPage extends StatefulWidget {

  const OptionsPage({ Key? key }) : super(key: key);

  @override
  State<OptionsPage> createState() => _OptionsPageState();

}

class _OptionsPageState extends State<OptionsPage> {

  void goBack() {
    Navigator.of(context).pop();
  }
  void reset() {
    showAlertDialogWidget(context, () async {
      await AppState.of(context).resetData();
      Navigator.of(context).pop();
    });
  }
  void goToDeveloperOptions() {
    Navigator.of(context).push(MaterialPageRoute(builder: ((context) => const DeveloperOptionsPage())));
  }

  static double pointSystemConstant = 20.2 / Constants.ratio; // equals 8px
  static VerticalGrid grid = VerticalGrid(count: 8, gutter: (pointSystemConstant * 2), margin: 0);
  static HorizontalGrid horizontalGrid = HorizontalGrid(count: 3, gutter: (pointSystemConstant * 2), margin: (pointSystemConstant * 4));

  showAlertDialogWidget(BuildContext context, void Function() onReset) {

    Widget cancelButton = TextButton(
      child: Text("Cancel", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Constants.black)),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = TextButton(
      child: Text("Reset", style: GoogleFonts.inter(fontWeight: FontWeight.w400, color: Constants.black50)),
      onPressed: () {
        Navigator.of(context).pop();
        onReset();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Attention!", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: Text("Do you really want to reset this app? All your data stored locally will be deleted!", style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: HeaderDelegate(
                pointSystemConstant: pointSystemConstant,
                definedVerticalGrid: grid.define(pageSafeAreaHeight()),
                horizontalGrid: horizontalGrid.define(MediaQuery.of(context).size.width),
                onGoBack: goBack,
                title: "Options",
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Option(
                  grid: grid.define(pageSafeAreaHeight()),
                  horizontalGrid: horizontalGrid.define(MediaQuery.of(context).size.width),
                  margin: horizontalGrid.margin,
                  bottomBorder: true,
                  pointSystemConstant: pointSystemConstant,
                  iconData: Icons.delete_forever,
                  text: "Reset",
                  onTap: reset
                ),
                Option(
                  grid: grid.define(pageSafeAreaHeight()),
                  horizontalGrid: horizontalGrid.define(MediaQuery.of(context).size.width),
                  margin: horizontalGrid.margin,
                  bottomBorder: true,
                  pointSystemConstant: pointSystemConstant,
                  iconData: Icons.developer_mode,
                  text: "Developer Options",
                  onTap: goToDeveloperOptions
                ),
              ]),
            )
          ],
        ),
      )
    );
  }

}

class DeveloperOptionsPage extends StatefulWidget {

  const DeveloperOptionsPage({ Key? key }) : super(key: key);

  @override
  State<DeveloperOptionsPage> createState() => _DeveloperOptionsPageState();

}
class _DeveloperOptionsPageState extends State<DeveloperOptionsPage> {
  
  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
  void changeMode() async {
    Mode newMode = AppState.of(context).mode == Mode.production ? Mode.development : Mode.production;

    setState(() => loading = true );

    await AppState.of(context).switchMode(newMode);

    setState(() => loading = false );
  }

  static double pointSystemConstant = 20.2 / Constants.ratio; // equals 8px
  static VerticalGrid grid = VerticalGrid(count: 8, gutter: (pointSystemConstant * 2), margin: 0);
  static HorizontalGrid horizontalGrid = HorizontalGrid(count: 3, gutter: (pointSystemConstant * 2), margin: (pointSystemConstant * 4));

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: HeaderDelegate(
                pointSystemConstant: pointSystemConstant,
                definedVerticalGrid: grid.define(pageSafeAreaHeight()),
                horizontalGrid: horizontalGrid.define(MediaQuery.of(context).size.width),
                onGoBack: () => goBack(context),
                title: "Options",
                subtitle: "Developer"
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Option(
                  grid: grid.define(pageSafeAreaHeight()),
                  horizontalGrid: horizontalGrid.define(MediaQuery.of(context).size.width),
                  margin: horizontalGrid.margin,
                  bottomBorder: true,
                  pointSystemConstant: pointSystemConstant,
                  iconData: Icons.developer_mode,
                  text: "Mode",
                  content: loading ? "..." : AppState.of(context).mode.displayName,
                  onTap: changeMode
                ),
              ]),
            )
          ],
        ),
      )
    );
  }
}

class HeaderDelegate extends SliverPersistentHeaderDelegate {

  HeaderDelegate({
    required this.pointSystemConstant,
    required this.definedVerticalGrid,
    required this.horizontalGrid,
    required this.onGoBack,
    required this.title,
    this.subtitle,
  });

  final double pointSystemConstant;
  final DefinedVerticalGrid definedVerticalGrid;
  final DefinedHorizontalGrid horizontalGrid;
  final void Function() onGoBack;
  final String title;
  final String? subtitle;

  double get height => (definedVerticalGrid.definedRowHeight * 2) + (definedVerticalGrid.gutter * 2);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      width: horizontalGrid.space,
      height: height,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: (horizontalGrid.margin - (2 * pointSystemConstant)), top: (horizontalGrid.margin - (2 * pointSystemConstant))),
            child: InkWell(
              onTap: onGoBack,
              child: Padding(
                padding: EdgeInsets.all(pointSystemConstant * 3),
                child: Icon(Icons.arrow_back_ios_new, size: pointSystemConstant * 4),
              )
            ),
          ),
          Center(
            child: Column(
              children: [
                subtitle != null ? Text(subtitle!, style: GoogleFonts.inter(fontSize: pointSystemConstant * 3, fontWeight: FontWeight.w400, color: Constants.black50)) : const Material(),
                subtitle != null ? SizedBox(height: pointSystemConstant) : const Material(),
                Text(title, style: GoogleFonts.inter(fontSize: pointSystemConstant * 4, fontWeight: FontWeight.w600))
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          )
        ],
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}