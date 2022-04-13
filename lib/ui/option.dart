import 'package:datura/ui/constants.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

class Option extends StatelessWidget {

  const Option({ 
    Key? key,
    required this.height,
    required this.pointSystemConstant,
    required this.margin,
    this.bottomBorder = true,

    required this.iconData,
    required this.text,
    required this.onTap,
    this.content
  }) : super(key: key);

  final double height;
  final double pointSystemConstant;
  final double margin;
  final bool bottomBorder;

  final IconData iconData;
  final String text;
  final void Function() onTap;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: height,
          decoration: BoxDecoration(
            border: Border(
              top: const BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio),
              bottom: bottomBorder ? const BorderSide(color: Constants.borderGrey, width: 2.52 / Constants.ratio) : BorderSide.none 
            )
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: margin),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(iconData, size: pointSystemConstant * 3),
                    SizedBox(width: pointSystemConstant * 2),
                    Text(text, style: GoogleFonts.inter(
                      fontSize: pointSystemConstant * 3,
                      fontWeight: FontWeight.w400
                    ))
                  ],
                ),
                content != null ? Text(content!, style: GoogleFonts.inter(
                  fontSize: pointSystemConstant * 3,
                  fontWeight: FontWeight.w400,
                  color: Constants.black75
                )) : const Material(),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
        ),
      ),
    );
  }
}