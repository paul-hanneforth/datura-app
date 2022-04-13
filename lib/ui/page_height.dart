import 'dart:ui';

double pageTopPadding() {
  final pixelRatio = window.devicePixelRatio;
  final paddingTop = window.padding.top / pixelRatio;
  return paddingTop;
}
double pageBottomPadding() {
  final pixelRatio = window.devicePixelRatio;
  final paddingBottom = window.padding.bottom / pixelRatio;
  return paddingBottom;
}
double pageSafeAreaHeight() {
  final pixelRatio = window.devicePixelRatio;
  final logicalScreenSize = window.physicalSize / pixelRatio;
  final logicalHeight = logicalScreenSize.height;
  final paddingTop = pageTopPadding();
  final paddingBottom = pageBottomPadding();
  final safeAreaHeight = logicalHeight - paddingTop - paddingBottom;
  
  return safeAreaHeight;
}