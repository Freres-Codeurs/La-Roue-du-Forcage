import 'dart:io';
import 'dart:ui';

class Quarter {
  final String image;
  final Color color;
  final isCustom;

  Quarter(this.image, this.color, this.isCustom);

  dynamic get asset => this.isCustom ? File(image) : "assets/images/$image.png";
  bool get iscustom => this.isCustom;
}
