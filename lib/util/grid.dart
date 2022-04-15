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

  DefinedHorizontalGrid define(double space) {
    return DefinedHorizontalGrid(
      count: count,
      gutter: gutter,
      margin: margin,
      space: space
    );
  }

}
class DefinedHorizontalGrid extends HorizontalGrid {


  const DefinedHorizontalGrid({
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

  double get definedColumnWidth => ((space - (2 * margin)) - ((count - 1) * gutter)) / count;

}