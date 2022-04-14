import 'package:datura/ui/constants.dart';
import 'package:datura/util/grid.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class AddButton extends StatefulWidget {
  const AddButton({ 
    Key? key,
    required this.pointSystemConstant,
    required this.grid,
    required this.weightSelectorInitialValue,
    required this.onSaveNewEntry
  }) : super(key:  key);

  final double pointSystemConstant;
  final DefinedVerticalGrid grid;
  final double Function() weightSelectorInitialValue;
  final void Function(double weight) onSaveNewEntry;
  
  @override
  State<AddButton> createState() => _AddButtonState ();
}

class _AddButtonState extends State<AddButton> {

  static const borderWidth = 2.52 / Constants.ratio;

  final ValueNotifier<double> numberSelector = ValueNotifier<double>(0);

  bool stateOpened = false;
  bool animationDone = false;

  @override
  void initState() {
    super.initState();

    numberSelector.value = widget.weightSelectorInitialValue();
  }

  Widget numberSelectorWidget() {
    final selectedTextStyle = GoogleFonts.inter(
			fontSize: widget.pointSystemConstant * 4,
			fontWeight: FontWeight.w500,
			color: Constants.black
		);
    final unselectedTextStyle = GoogleFonts.inter(
			fontSize: widget.pointSystemConstant * 3,
			fontWeight: FontWeight.w400,
			color: Constants.black50
		);

    String numberAsText(num number) {
      if(number % 1 != 0) {
        return number.toDouble().toString();
      }
      
      return number.toStringAsFixed(0);
    }

    const duration = Duration(milliseconds: 800);
    const curve = Curves.decelerate;

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      height: stateOpened ? ((widget.grid.definedRowHeight + widget.grid.gutter) * 2) + MediaQuery.of(context).padding.bottom : (widget.grid.definedRowHeight + widget.grid.gutter),
      onEnd: () => animationDone = true,
      child: Align(
        alignment: Alignment.topCenter,
        child: Dismissible(
          background: const Material(color: Constants.notQuiteBlack),
          key: UniqueKey(),
          direction: DismissDirection.down,
          resizeDuration: null,
          onDismissed: (direction) {
            setState(() {
              stateOpened = false;
            });
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: widget.grid.definedRowHeight + widget.grid.gutter,
              decoration: const BoxDecoration(
                color: Constants.white,
                border: Border(
                  top: BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio)
                )
              ),
              child: AnimatedOpacity(
                duration: duration,
                curve: curve,
                opacity: stateOpened ? 1 : 0,
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
              ),
          ),
        ),
      ),
    );
  }
  Widget addButtonContent() {
    return Column(
      key: stateOpened ? const ValueKey<int>(0) : const ValueKey<int>(1),
      children: [
        Icon(stateOpened ? Icons.done : Icons.add, size: widget.pointSystemConstant * 5, color: Constants.notQuiteBlack),
        SizedBox(height: widget.pointSystemConstant),
        Text(stateOpened? "Save new Entry" : "Add new Entry",style: GoogleFonts.inter(
          fontSize: widget.pointSystemConstant * 2,
          fontWeight: FontWeight.w400
        ))
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }

  @override
  Widget build(BuildContext context) {
    // set numberSelector to the current weightSelectorInitialValue()
    numberSelector.value = widget.weightSelectorInitialValue();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        numberSelectorWidget(),
        Container(
          height: widget.grid.definedRowHeight + widget.grid.gutter + MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Constants.borderGrey, width: borderWidth),
            )
          ),
          child: Material(
            color: Constants.white,
            child: InkWell(
              onTap: () {
                if(stateOpened && animationDone) {
                  widget.onSaveNewEntry(numberSelector.value);
                }
                animationDone = false;
                setState(() {
                  stateOpened = !stateOpened;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    child: addButtonContent()
                  )
                ),
              ),
            ),
          ),
        ), 
      ]
    );
  }

}