class VerticalGrid {
  
  const VerticalGrid({
    required this.count, 
    required this.gutter, 
    required this.margin 
  });

  final int count;
  final double gutter;
  final double margin;

  double rowHeight(double space) {
    return ((space - margin) - ((count - 1) * gutter)) / count;
  }

  DefinedVerticalGrid define(double space) {
    return DefinedVerticalGrid(
      count: count,
      gutter: gutter,
      margin: margin,
      space: space
    );
  }

  // double getDeviceHeight() {
  //   var pixelRatio = window.devicePixelRatio;

  //   //Size in physical pixels
  //   var physicalScreenSize = window.physicalSize;
  //   var physicalWidth = physicalScreenSize.width;
  //   var physicalHeight = physicalScreenSize.height;

  //   //Size in logical pixels
  //   var logicalScreenSize = window.physicalSize / pixelRatio;
  //   var logicalWidth = logicalScreenSize.width;
  //   var logicalHeight = logicalScreenSize.height;
  //   print("height:" + logicalHeight.toString());

  //   //Padding in physical pixels
  //   var padding = window.padding;

  //   //Safe area paddings in logical pixels
  //   var paddingLeft = window.padding.left / window.devicePixelRatio;
  //   var paddingRight = window.padding.right / window.devicePixelRatio;
  //   var paddingTop = window.padding.top / window.devicePixelRatio;
  //   var paddingBottom = window.padding.bottom / window.devicePixelRatio;

  //   //Safe area in logical pixels
  //   var safeWidth = logicalWidth - paddingLeft - paddingRight;
  //   var safeHeight = logicalHeight - paddingTop - paddingBottom;
  //   print("height:" + safeHeight.toString());

  //   return logicalHeight;
  // }

}
class DefinedVerticalGrid extends VerticalGrid {

  const DefinedVerticalGrid({
    required count,
    required gutter,
    required margin,
    required this.space
  }) : super(
    count: count,
    gutter: gutter,
    margin: margin
  );

  final double space;

  double get definedRowHeight => ((space - (2 * margin)) - ((count - 1) * gutter)) / count;

}

class HorizontalGrid {

  const HorizontalGrid({
    required this.count,
    required this.gutter,
    required this.margin
  });

  final int count;
  final double gutter;
  final double margin;

  double columnWidth(double space) => ((space - (2 * margin)) - ((count - 1) * gutter)) / count;

}