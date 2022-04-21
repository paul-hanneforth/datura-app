import 'package:datura/ui/constants.dart';
import "package:flutter/material.dart";

class Panel extends StatelessWidget {
  const Panel({ 
    Key? key,
    required this.pointSystemConstant,
    required this.width,
    required this.height,
    required this.child,

    this.bottomBorder = false,
  }) : super(key: key);

  final double pointSystemConstant;
  final double width;
  final double height;
  final Widget child;

  final bool bottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio),
          bottom: bottomBorder ? const BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio) : BorderSide.none 
        )
      ),
      child: child,
    );
  }
}